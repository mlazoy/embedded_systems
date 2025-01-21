#include "stdio.h"
#include "string.h"

#include "common_utils.h"
#include "hal_data.h"


#include "image.h"
#include "phods.h"

void hal_entry(void) {

  // Initialize your variables here
  int motion_vectors_x[N / B][M / B], motion_vectors_y[N / B][M / B], i, j;

  uint32_t timer;

  // Code to initialize the DWT->CYCCNT register
  CoreDebug->DEMCR |= 0x01000000;
  ITM->LAR = 0xC5ACCE55;
  DWT->CYCCNT = 0;
  DWT->CTRL |= 1;

  // Initial

  APP_PRINT("Embedded Systems - Lab1\n\n");
  APP_PRINT("Omada 24 - Maria Lazou, Avramidis Stavros\n\n");

  APP_PRINT("System Running @%u MHz\n\n", SystemCoreClock / 1000000);

  APP_PRINT("Running for B: %d\n", Bx, By);

  for (int i = 0; i < 10; i++) {
    timer = DWT->CYCCNT;
    phods_motion_estimation_naive(current, previous, motion_vectors_x,
                                  motion_vectors_y);
    timer = DWT->CYCCNT - timer;

    APP_PRINT("Time for naive loop[%d]: %u\n", i, timer);
  }

  APP_PRINT("\n");

  for (int i = 0; i < 10; i++) {
    timer = DWT->CYCCNT;
    phods_motion_estimation_opt(current, previous, motion_vectors_x,
                                motion_vectors_y);
    timer = DWT->CYCCNT - timer;

    APP_PRINT("Time for opt loop[%d]: %u\n", i, timer);
  }

  while (1)
    ;
}
