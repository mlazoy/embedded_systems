import csv

resfile = os.path.join(img_dir, "metrics.csv")

def save_results():
  with open(resfile, mode='w', newline='') as file:
      writer = csv.writer(file)
      writer.writerow(['BITS', 'index', 'Maximum Pixel Error', 'Peak Signal-to_Noise Ratio'])

      for key in max_err_vals:
          b, i = key
          max_err = max_err_vals[key]
          psnr_val = psnr_vals[key]
          writer.writerow([b, i, max_err, psnr_val])

def plot_results():
  fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(8, 8))
  ax1.set_facecolor("#d3d3d3")
  ax2.set_facecolor("#d3d3d3")
  colors =  [
    "#1f77b4",  # Blue
    "#2ca02c",  # Green
    "#9467bd"  #Purple
  ]

  # Plot max_err values
  for i in idx:
      ax1.plot(bits, [max_err_vals[(b, i)] for b in bits], color = colors[i-10], marker='o', label=f'idx = {i}')
  ax1.grid()
  ax1.set_xlabel("#BITS")
  ax1.set_ylabel("max_error")
  ax1.set_title("Maximum Pixel Error vs BITS for indices: {10, 11, 12}",fontsize=12,fontstyle='italic')
  ax1.legend()

  # Plot psnr values
  for i in idx:
      ax2.plot(bits, [psnr_vals[(b, i)] for b in bits], color = colors[i-10], marker='o', label=f'idx = {i}')
  ax2.grid()
  ax2.set_xlabel("#BITS")
  ax2.set_ylabel("psnr")
  ax2.set_title("Peak Signal-to-Noise Ratio vs BITS for image indices: {10, 11, 12}",fontsize=12,fontstyle='italic')
  ax2.legend()

  plt.tight_layout()
  plt.show()
  plt.savefig(os.path.join(img_dir, "metric_plots.png"))

