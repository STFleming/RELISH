#include <stdio.h>
#include <stdlib.h>
#include "performance_counter.h"
#include "softfloat.c"
#include "mm.h"
#include "vaddr.h"

#define SIZE 20000 
#define L2_SIZE 64000

unsigned short lfsr = 0xACE1u;
unsigned bit;

unsigned lsfr_rand()
{
  bit  = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5) ) & 1;
  return lfsr =  (lfsr >> 1) | (bit << 15);
}

volatile unsigned L2_flusher[L2_SIZE];

volatile struct node {
	float32 data;
	struct node *nxt;
} *head;

volatile struct inputParam{
	volatile unsigned *l1_pagetable;
	volatile struct node * h;
};

__attribute__((noinline))void addElement(float32 data)
{
	struct node *item;
	item = (struct node*)mm_malloc(sizeof(struct node)); 
	item->data = data;
	item->nxt = NULL;

	struct node *tmp = head;
	if(head == NULL) {
		head = item;
	}
	else {
		while(tmp->nxt != NULL) {
			tmp = tmp->nxt;
		}	
		tmp->nxt = item;
	}
	return; 
}

__attribute__((noinline))int listAverage(volatile struct inputParam * in)
{
	volatile unsigned *l1_pt = in->l1_pagetable;
	volatile struct node * tmp = in->h;
	int itemCount = 0;
	float32 accumulator = int32_to_float32(0);
	while(readVirt(&tmp->nxt, l1_pt) != NULL){
		itemCount++;
		float32 tmp_dat = readVirt(&tmp->data, l1_pt);
		accumulator = float32_add(accumulator, tmp_dat);
		tmp = readVirt(&tmp->nxt, l1_pt);
	}
	return float32_to_int32(float32_div(accumulator, int32_to_float32(itemCount)));
}

//Flushes the L2 cache
void l2_cache_flush()
{
	for(int i=0; i<L2_SIZE; i++)
		L2_flusher[i] = i;		 
	return;	
}

//swaps the position of the first and second items in the linked list @ head
void swap(volatile struct node * h, unsigned first, unsigned second)
{
	if(first == 0 || second == 0)
		return; 
	if(first == second)
		return;
	volatile struct node * a_p = h;
	for(int i=0; i<(first-1); i++)
		a_p = a_p->nxt;
	struct node *a = a_p->nxt;

	volatile struct node * b_p = h;
	for(int i=0; i<(second-1); i++)
		b_p = b_p->nxt;
	struct node *b = b_p->nxt;

	//Now we have all the pointers we need to do the swap
	struct node * t1; //temp pointer
	if(a_p == b || b_p == a)
		return;
	a_p->nxt = b;
	t1 = b->nxt;
	b->nxt = a->nxt;
	b_p->nxt = a;
	a->nxt = t1;
	
	return;
}

int main() {
	printf("starting listAverage example.\n");
 	mm_init();
	head = NULL;

	printf("head=0x%x\n", head);
	printf("Constructing List...");
	for(int i=0; i<SIZE; i++)
		addElement(int32_to_float32(i));
	printf("done\n");

	//printf("shuffling list...");
	//for(int i=0; i<SIZE; i++)
	//	swap(head,lsfr_rand() % SIZE, lsfr_rand() % SIZE);
	//printf("done\n");

	volatile struct inputParam parameters;
	parameters.h = head;

	printf("executing average...");
	int res;
	legup_start_counter(0);
	//res = listAverage(&parameters);
	res = listAverage(head);
	unsigned time = legup_stop_counter(0);
	printf("done\n\n");

        printf("Result: %d\n", res);
        printf("Performance: %d\n", time);

	return 1;
}
