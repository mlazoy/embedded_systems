{
  const int i = 0;

  distx = 0;
  disty = 0;

  /*For all pixels in the block*/
  for (k = 0; k < B; k++) {
    const int B_times_x_plus_vec_x_xy_plus_k = B_times_x_plus_vec_x_xy + k;

    for (l = 0; l < B; l++) {
      const int B_times_y_plus_vec_y_xy_plus_l = B_times_y_plus_vec_y_xy + l;

      const int B_times_y_plus_vec_y_xy_plus_l = B_times_y_plus_vec_y_xy + l;

      p1 = current[B_times_x + k][B_times_y + l];

      if ((B_times_x_plus_vec_x_xy_plus_k) < 0 ||
          (B_times_x_plus_vec_x_xy_plus_k) > (N - 1) ||
          (B_times_y_plus_vec_y_xy_plus_l) < 0 ||
          (B_times_y_plus_vec_y_xy_plus_l) > (M - 1)) {
        p2 = 0;
      } else {
        p2 = previous[B_times_x_plus_vec_x_xy_plus_k]
                     [B_times_y_plus_vec_y_xy_plus_l];
      }

      if ((B_times_x_plus_vec_x_xy_plus_k) < 0 ||
          (B_times_x_plus_vec_x_xy_plus_k) > (N - 1) ||
          (B_times_y_plus_vec_y_xy_plus_l) < 0 ||
          (B_times_y_plus_vec_y_xy_plus_l) > (M - 1)) {
        q2 = 0;
      } else {
        q2 = previous[B_times_x_plus_vec_x_xy_plus_k]
                     [B_times_y_plus_vec_y_xy_plus_l];
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