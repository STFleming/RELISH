#ifndef _UTIL_H
#define _UTIL_H

#include <stddef.h>
#include <stdint.h>
#define SIZE 1024000 

volatile struct mem {
  char storage[SIZE];
} heap;

char *ptr = heap.storage;

__attribute__((always_inline)) void *mem_heap_lo() {
  return heap.storage;
}

__attribute__((always_inline)) void *mem_heap_hi() {
  return (ptr - 1);
}

__attribute__((always_inline)) void *mem_sbrk(int size) {
  void *p = ptr;
  ptr += size;
  // should check for reaching max heap size
  return p;
}

__attribute__((always_inline)) void memcpy_8(uint64_t * d, const uint64_t * s, size_t n)
{
    uint64_t * dt = d;
    const uint64_t * st = s;
    n >>= 3;
    while (n--)
        *dt++ = *st++;
}

#endif
