#include <stdio.h>
#define RADIUS 3;
#define BLOCK_SIZE 12;
#define ARRAY_SIZE 78;

int *array_of_ones(int size);
void print_array(int *array, int size) ;

__global__ void stencil_1d(int *in, int *out) {
  __shared__ int temp[BLOCK_SIZE + 2 * RADIUS];
  int gindex = threadIdx.x + blockIdx.x * blockDim.x;
  int lindex = threadIdx.x + RADIUS;

  temp[lindex] = in[gindex];
  if (threadIdx.x < RADIUS) {
    temp[lindex - RADIUS] = in[gindex - RADIUS];
    temp[lindex - BLOCK_SIZE] = in[gindex + BLOCK_SIZE];
  }

  __syncthreads();

  int result = 0;
  for (int offset = -RADIUS ; offset <= RADIUS ; offset++)
    result += temp[lindex + offset];

  out[gindex] = result;
}

int main(void) {
  int thread_size = RADIUS * 2 + 1;
  int *in = array_of_ones(ARRAY_SIZE);
  int *out;
  int size = ARRAY_SIZE * sizeof(int);

  cudaMalloc((void **)&d_a, ARRAY_SIZE);
  stencil_1d<<<BLOCK_SIZE, thread_size>>>(in, out);

  print_array(in, ARRAY_SIZE);
  print_array(out, ARRAY_SIZE);
  free(in); free(out);

  return 0;
}

void print_array(int *array, int size) {
  printf("\n");
  for (int i = 0; i < size; ++i) {
    printf("%d ", array[i]);
  }
  printf("\n");
}

int *array_of_ones(int size) {
  array = (int *)malloc(size);
  for (int i = 0; i < size; ++i) {
    array[i] = 1;
  }
  return array;
}
