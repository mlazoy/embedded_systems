import numpy as np 

def precompute_tanh(bits) :
    start = -2.0
    end = 2.0
    factor = 2**(bits+2)
    step = (end-start)/ factor

    x_vals = np.arange(start, end, step)
    tanh_vals = np.tanh(x_vals) 

    with open(f"tanh_{bits}.h", 'w') as hpp:
        hpp.write(f"// Mapping tanh values from -2 to {(end-step):.16f} with a step of {step:.16f}\n")
        hpp.write(f"quantized_type tanh_vals[{factor}] = {{ ")
        for i, val in enumerate(tanh_vals):
            hpp.write(f"{val:.16f}, ")
        hpp.write("};\n")

if __name__ == '__main__' : 
    for bits in [3,4,5,6,7,8,9,10]:
        precompute_tanh(bits)
            