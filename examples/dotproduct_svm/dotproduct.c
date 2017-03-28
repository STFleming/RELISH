#include <stdio.h>
#include <stdlib.h>
#include "softfloat.c"
#include "vaddr.h"

#define SIZE 30 
#define L2_SIZE 64000

volatile struct inputs{
	int size;
	volatile unsigned *l1_pagetable;
	float32 *a;
	float32 *b;
};


__attribute__((noinline))int dotproduct(volatile struct inputs* in)
{
	volatile int size = in->size;
	volatile float32 *A = in->a;
	volatile float32 *B = in->b;
	volatile unsigned * l1_pagetable = in->l1_pagetable;
	float32 acc = 0.0;
	float32 tmp1 = 0.0;
	float32 tmp2 = 0.0;
	for(int i=0; i< size; i++){
		tmp1 = readVirt(A+i, l1_pagetable);
		tmp2 = readVirt(B+i, l1_pagetable);
		acc = float32_add(acc, float32_mul(tmp1, tmp2));
	}
	return float32_to_int32(acc);
}

int main() {
	printf("starting debug.\n");

	volatile unsigned * l1_pagetable = (volatile unsigned *)0x34001000;
	volatile unsigned *page_start = (volatile unsigned *)0x34002000;
        volatile unsigned *paddr_start = (volatile unsigned *)0x34100000;
        setupPageTables(l1_pagetable, paddr_start, page_start);

	volatile int *IN_1 = (volatile unsigned * )0x00002004;
	volatile int *IN_2 = (volatile unsigned * )0x00002004;

	printf("Constructing List...");
	for(int i=0; i<SIZE; i++) {
		write2virt(IN_1[i], i, l1_pagetable);
		write2virt(IN_2[i], 2*i, l1_pagetable);
	}
	printf("done\n");
	

	volatile struct inputs parameters;
	parameters.size = SIZE;
	parameters.a = IN_1;
	parameters.b = IN_2;
	parameters.l1_pagetable = l1_pagetable;

	printf("executing circuit...");
	int res;
	res = dotproduct(&parameters);
	printf("done\n\n");

        printf("Result: %d\n", res);

	return 1;
}
