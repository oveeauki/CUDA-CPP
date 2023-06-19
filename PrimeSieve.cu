#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "chrono"

#define N 99999990

__global__ void sieve(int *primes, int n) {
    int i, j;
    for (i = blockIdx.x * blockDim.x + threadIdx.x + 2; i <= n; i += blockDim.x * gridDim.x) {
        if (primes[i]) {
            for (j = i * i; j <= n; j += i) {
                primes[j] = 0;
            }
        }
    }
}

int main() {
    int *primes, i, count = 0;
    cudaMallocManaged(&primes, (N + 1) * sizeof(int));
    for (i = 0; i <= N; i++) {
        primes[i] = 1;
    }
    primes[0] = 0;
    primes[1] = 0;

    int blockSize = 1024;
    int numBlocks = (N + blockSize - 1) / blockSize;
    auto start = std::chrono::high_resolution_clock::now();

    sieve<<<numBlocks, blockSize>>>(primes, N);

    cudaDeviceSynchronize();
    auto end = std::chrono::high_resolution_clock::now();
    auto elapsed_seconds = std::chrono::duration_cast<std::chrono::seconds>(end - start).count();
    auto elapsed_minutes = elapsed_seconds / 60;
    elapsed_seconds = elapsed_seconds % 60;
    for (i = 2; i <= N; i++) {
        if (primes[i]) {
            count++;
        }
    }

    printf("Number of primes up to %d: %d\nElapsed time:%dm %ds\n",N,count,elapsed_minutes,elapsed_seconds);
    cudaFree(primes);
    return 0;
}
