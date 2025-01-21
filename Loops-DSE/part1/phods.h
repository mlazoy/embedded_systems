#include "inttypes.h"

#define N (10) /* Frame dimension for QCIF format */
#define M (10) /* Frame dimension for QCIF format */
#define B (5)  /* Block size*/
#define p                                                                      \
  (7) /* Search space. Restricted in a [-p,p] region around the  original      \
         location of the block. */


__attribute__((always_inline)) 
inline int32_t sub_and_abs(int32_t a, int32_t b) {
  int32_t result;
  __asm__("subs %0, %1, %2\n" // result = a - b, sets flags
          "it mi\n" // If result is negative (MI), execute next instruction
          "negmi %0, %0\n" // If negative, result = -result
          : "=r"(result)   // output
          : "r"(a), "r"(b) // inputs
          : "cc"           // clobbers the condition codes
  );
  return result;
}

void phods_motion_estimation(const int current[N][M], const int previous[N][M],
                             int vectors_x[N / B][M / B],
                             int vectors_y[N / B][M / B]) {
  int x, y, i, k, l, p1, p2, q2, distx, disty, S, min1, min2, bestx, besty;

  distx = 0;
  disty = 0;

  /*For all blocks in the current frame*/
  int B_times_x = 0;

  for (x = 0; x < N / B; x++) {

    int B_times_y = 0;

    for (y = 0; y < M / B; y++) {

      /*Initialize the vector motion matrices*/
      vectors_x[x][y] = 0;
      vectors_y[x][y] = 0;

      S = 4;

      while (S > 0) {
        min1 = 255 * B * B;
        min2 = 255 * B * B;

        /*For all candidate blocks in X and Y dimension*/

        const int vec_x_xy = vectors_x[x][y];
        const int vec_y_xy = vectors_y[x][y];
        const int B_times_x_plus_vec_x_xy = B_times_x + vec_x_xy;
        const int B_times_y_plus_vec_y_xy = B_times_y + vec_y_xy;

        {
          const int i = -S;
          distx = 0;
          disty = 0;

          const int B_times_x_plus_vec_x_xy_plus_i =
              B_times_x_plus_vec_x_xy + i;
          const int B_times_y_plus_vec_y_xy_plus_i =
              B_times_y_plus_vec_y_xy + i;

          /*For all pixels in the block*/
          for (k = 0; k < B; k++) {
            const int B_times_x_plus_vec_x_xy_plus_i_plus_k =
                B_times_x_plus_vec_x_xy_plus_i + k;

            const int B_times_x_plus_vec_x_xy_plus_k =
                B_times_x_plus_vec_x_xy + k;

            const int B_times_x_plus_k = B_times_x + k;

            for (l = 0; l < B; l++) {
              const int B_times_y_plus_vec_y_xy_plus_i_plus_l =
                  B_times_y_plus_vec_y_xy_plus_i + l;

              const int B_times_y_plus_vec_y_xy_plus_l =
                  B_times_y_plus_vec_y_xy + l;

              p1 = current[B_times_x_plus_k][B_times_y + l];

              if ((B_times_x_plus_vec_x_xy_plus_i_plus_k) < 0 ||
                  (B_times_x_plus_vec_x_xy_plus_i_plus_k) > (N - 1) ||
                  (B_times_y_plus_vec_y_xy_plus_l) < 0 ||
                  (B_times_y_plus_vec_y_xy_plus_l) > (M - 1)) {
                p2 = 0;
              } else {
                p2 = previous[B_times_x_plus_vec_x_xy_plus_i + k]
                             [B_times_y_plus_vec_y_xy_plus_l];
              }

              if ((B_times_x_plus_vec_x_xy_plus_k) < 0 ||
                  (B_times_x_plus_vec_x_xy_plus_k) > (N - 1) ||
                  (B_times_y_plus_vec_y_xy_plus_i_plus_l) < 0 ||
                  (B_times_y_plus_vec_y_xy_plus_i_plus_l) > (M - 1)) {
                q2 = 0;
              } else {
                q2 = previous[B_times_x_plus_vec_x_xy_plus_k]
                             [B_times_y_plus_vec_y_xy_plus_i_plus_l];
              }

              distx += sub_and_abs(p1, p2);
              disty += sub_and_abs(p1, q2);
            }
          }

          if (distx < min1) {
            min1 = distx;
            bestx = i;
          }

          if (disty < min2) {
            min2 = disty;
            besty = i;
          }
        }

        {
          const int i = 0;

          distx = 0;
          disty = 0;

          /*For all pixels in the block*/
          for (k = 0; k < B; k++) {
            const int B_times_x_plus_vec_x_xy_plus_k =
                B_times_x_plus_vec_x_xy + k;

            const int B_times_x_plus_k = B_times_x + k;

            for (l = 0; l < B; l++) {
              const int B_times_y_plus_vec_y_xy_plus_l =
                  B_times_y_plus_vec_y_xy + l;

              p1 = current[B_times_x_plus_k][B_times_y + l];

              if ((B_times_x_plus_vec_x_xy_plus_k) < 0 ||
                  (B_times_x_plus_vec_x_xy_plus_k) > (N - 1) ||
                  (B_times_y_plus_vec_y_xy_plus_l) < 0 ||
                  (B_times_y_plus_vec_y_xy_plus_l) > (M - 1)) {
                p2 = 0;
              } else {
                p2 = previous[B_times_x_plus_vec_x_xy_plus_k]
                             [B_times_y_plus_vec_y_xy_plus_l];
              }

              int res = sub_and_abs(p1, p2);
              distx += res;
              disty += res;
            }
          }

          if (distx < min1) {
            min1 = distx;
            bestx = i;
          }

          if (disty < min2) {
            min2 = disty;
            besty = i;
          }
        }

        {
          const int i = S;
          distx = 0;
          disty = 0;

          const int B_times_x_plus_vec_x_xy_plus_i =
              B_times_x_plus_vec_x_xy + i;
          const int B_times_y_plus_vec_y_xy_plus_i =
              B_times_y_plus_vec_y_xy + i;

          /*For all pixels in the block*/
          for (k = 0; k < B; k++) {
            const int B_times_x_plus_vec_x_xy_plus_i_plus_k =
                B_times_x_plus_vec_x_xy_plus_i + k;

            const int B_times_x_plus_vec_x_xy_plus_k =
                B_times_x_plus_vec_x_xy + k;

            const int B_times_x_plus_k = B_times_x + k;

            for (l = 0; l < B; l++) {
              const int B_times_y_plus_vec_y_xy_plus_i_plus_l =
                  B_times_y_plus_vec_y_xy_plus_i + l;

              const int B_times_y_plus_vec_y_xy_plus_l =
                  B_times_y_plus_vec_y_xy + l;

              p1 = current[B_times_x_plus_k][B_times_y + l];

              if ((B_times_x_plus_vec_x_xy_plus_i_plus_k) < 0 ||
                  (B_times_x_plus_vec_x_xy_plus_i_plus_k) > (N - 1) ||
                  (B_times_y_plus_vec_y_xy_plus_l) < 0 ||
                  (B_times_y_plus_vec_y_xy_plus_l) > (M - 1)) {
                p2 = 0;
              } else {
                p2 = previous[B_times_x_plus_vec_x_xy_plus_i + k]
                             [B_times_y_plus_vec_y_xy_plus_l];
              }

              if (B_times_x_plus_vec_x_xy_plus_k < 0 ||
                  B_times_x_plus_vec_x_xy_plus_k > (N - 1) ||
                  (B_times_y_plus_vec_y_xy_plus_i_plus_l) < 0 ||
                  (B_times_y_plus_vec_y_xy_plus_i_plus_l) > (M - 1)) {
                q2 = 0;
              } else {
                q2 = previous[B_times_x_plus_vec_x_xy_plus_k]
                             [B_times_y_plus_vec_y_xy_plus_i_plus_l];
              }

              distx += sub_and_abs(p1, p2);
              disty += sub_and_abs(p1, q2);
            }
          }

          if (distx < min1) {
            min1 = distx;
            bestx = i;
          }

          if (disty < min2) {
            min2 = disty;
            besty = i;
          }
        }

        S = S / 2;
        vectors_x[x][y] += bestx;
        vectors_y[x][y] += besty;
      }

      // Reduce B * y to addition
      B_times_y += B;
    }

    // Reduce B * x
    B_times_x += B;
  }
}