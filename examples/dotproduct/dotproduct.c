#include <stdio.h>
#include <stdlib.h>
#include "softfloat.c"

#define SIZE 30 
#define L2_SIZE 64000

volatile struct inputs{
	int size;
	float32 *a;
	float32 *b;
};


__attribute__((noinline))int dotproduct(volatile struct inputs* in)
{
	int itemCount = 0;
	volatile int size = in->size;
	volatile float32 *A = in->a;
	volatile float32 *B = in->b;
	float32 acc = 0.0;
	float32 tmp1 = 0.0;
	float32 tmp2 = 0.0;
	for(int i=0; i< size; i++){
		acc = float32_add(acc, float32_mul(*(A + i), *(B + i)));
	}
	return float32_to_int32(acc);
}

int main() {
	printf("starting debug.\n");

	volatile int IN_1[SIZE];
	volatile int IN_2[SIZE];

	printf("Constructing List...");
	for(int i=0; i<SIZE; i++) {
		IN_1[i] = i;//int32_to_float32(i);
		IN_2[i] = i*2;
	}
	printf("done\n");
	
	volatile struct inputs parameters;
	parameters.size = SIZE;
	parameters.a = &IN_1[0];
	parameters.b = &IN_2[0];

	printf("executing circuit...");
	int res;
	res = dotproduct(&parameters);
	printf("done\n\n");

        printf("Result: %d\n", res);

	return 1;
}
