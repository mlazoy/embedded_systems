#include <stdio.h>

#include "phods.h"

int current[N][M] = {{34, 72, 19, 85, 12, 57, 61, 98, 13, 41},
                     {23, 91, 47, 32, 65, 76, 28, 15, 89, 53},
                     {18, 74, 66, 22, 49, 83, 92, 37, 55, 31},
                     {45, 13, 56, 27, 88, 40, 51, 39, 21, 64},
                     {77, 99, 35, 53, 71, 62, 16, 87, 42, 78},
                     {90, 11, 44, 69, 25, 34, 73, 95, 58, 26},
                     {52, 20, 63, 80, 36, 54, 93, 30, 43, 70},
                     {67, 82, 14, 59, 24, 38, 50, 96, 48, 29},
                     {17, 60, 84, 33, 46, 19, 75, 79, 68, 94},
                     {81, 85, 26, 31, 55, 22, 69, 17, 97, 12}};

int previous[N][M] = {{82, 19, 94, 38, 41, 23, 55, 87, 12, 74},
                      {36, 88, 15, 43, 60, 97, 27, 69, 32, 90},
                      {50, 66, 13, 75, 29, 84, 49, 18, 33, 92},
                      {64, 21, 98, 37, 45, 58, 91, 26, 72, 14},
                      {81, 39, 59, 17, 93, 35, 77, 54, 48, 63},
                      {11, 68, 79, 24, 56, 31, 46, 85, 99, 22},
                      {52, 44, 16, 30, 95, 67, 40, 73, 25, 89},
                      {61, 47, 86, 20, 42, 70, 53, 78, 34, 57},
                      {83, 10, 28, 96, 65, 19, 62, 51, 80, 38},
                      {14, 41, 23, 92, 75, 55, 99, 12, 31, 68}};

int main() {
  int motion_vectors_x[N / B][M / B] = {0};
  int motion_vectors_y[N / B][M / B] = {0};
  int i, j;

  phods_motion_estimation(current, previous, motion_vectors_x,
                          motion_vectors_y);

  // Print the motion vectors
  for (i = 0; i < N / B; i++) {
    for (j = 0; j < M / B; j++) {
      printf("%4d", motion_vectors_x[i][j]);
    }
    puts("\n");
  }
  puts("------\n");

  for (i = 0; i < N / B; i++) {
    for (j = 0; j < M / B; j++) {
      printf("%4d", motion_vectors_y[i][j]);
    }
    printf("\n");
  }

  printf("Done...\n");
}