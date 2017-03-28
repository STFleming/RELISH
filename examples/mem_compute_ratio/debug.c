#include <stdio.h>
#include <stdlib.h>
#include "performance_counter.h"
#include "softfloat.c"

#define TSIZE 100
#define PSIZE 30

#define L2_SIZE 64000

#define MEM 4
#define COMPUTE 30

volatile struct inputs{
	int compute;
	int mem;
	int psize;
	float32 *array;
};

__attribute__((noinline))float32 computeloop(float32 *t, int compute)
{
	float32 acc = 0.0;
	for(int c=0; c<compute; c++) {
		acc = float32_add(acc , t[c]);
	}
	return acc;
}

__attribute__((noinline))int debug(volatile struct inputs* a)
{
	int itemCount = 0;
	volatile float32 *in = a->array;
	volatile int compute = a->compute;
	volatile int mem = a->mem;
	volatile int psize = a->psize;
	float32 t[TSIZE];
	float32 acc = 0.0;
	
	for(int i=0; i< psize; i++){
	
		//mem portion
		for(int m=0; m<mem; m++) {
			t[m] = in[m];
		}
		//compute portion
		acc = float32_add(acc, computeloop(t, compute)); 
	}

	return float32_to_int32(acc);
}

int main() {
	printf("starting debug.\n");

	volatile float32 IN[TSIZE];

	printf("Constructing List...");
	for(int i=0; i<TSIZE; i++)
		IN[i] = int32_to_float32(i);
	printf("done\n");

	for(int i=0; i<TSIZE; i++)
		printf("IN[%d] = %d\n", i, IN[i]);
	
	volatile struct inputs parameters;
	parameters.compute = COMPUTE;
	parameters.array = &IN[0];
	parameters.mem = MEM;
	parameters.psize = PSIZE;

	volatile float32 *a = &IN[0];

	printf("executing circuit...");
	int res;
	legup_start_counter(0);
	res = debug(&parameters);
	//res = debug(a);
	unsigned time = legup_stop_counter(0);
	printf("done\n\n");

        printf("Result: %d\n", res);
        printf("Performance: %d\n", time);

	return 1;
}
