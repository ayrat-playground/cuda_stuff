#include <stdio.h>
#define N 512

__global__ void add(int *a, int *b, int *c) {
  c[blockIdx.x] = a[blockIdx.x] + b[blockIdx.x];
}

void array_of_ones(int *array, int size);

void print_array(int *array, int size);

int main(void) {
  int *a, *b, *c;
  int *d_a, *d_b, *d_c;
  int size = N * sizeof(int);

  cudaMalloc((void **)&d_a, size);
  cudaMalloc((void **)&d_b, size);
  cudaMalloc((void **)&d_c, size);

  a = (int *)malloc(size); array_of_randoms(a, N); print_array(a, N);
  b = (int *)malloc(size); array_of_randoms(b, N); print_array(b, N);
  c = (int *)malloc(size);

  cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

  add<<<N,1>>>(d_a, d_b, d_c);

  cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);
  print_array(c, N);

  free(a); free(b); free(c);
  cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
  return 0;
}

void array_of_ransoms(int *array, int size) {
  for (int i = 0; i < size; ++i) {
    array[i] = rand() % 10 + 1;
  }
}

void print_array(int *array, int size) {
  printf("\n");
  for (int i = 0; i < size; ++i) {
    printf("%d ", array[i]);
  }
  printf("\n");
}
