#include "network.h"
#include "weight_definitions.h"
#include "tanh.h"

l_quantized_type ReLU(l_quantized_type res)
{
#pragma HLS inline
	if (res < 0)
		return 0;

	return res;
}

l_quantized_type tanh(l_quantized_type res)
{
	#pragma HLS inline
	#pragma HLS pipeline II=1
	if (res >= 2)
		return 1;
	else if (res < -2)
		return -1;
	else
	{
		ap_int <BITS+2> i = res.range(); //prepare result to match tanh value
		return tanh_vals[(BITS_EXP/2) + i.to_int()];
	}

}

void forward_propagation(float *x, float *y)
{
	quantized_type xbuf[N1];
	l_quantized_type layer_1_out[M1];
	l_quantized_type layer_2_out[M2];

	#pragma HLS array_partition variable=W1 factor=15 dim=2
	#pragma HLS array_partition variable=layer_1_out factor=15
	#pragma HLS array_partition variable=xbuf factor=15

	#pragma HLS array_partition variable=W2 factor=15 dim=1
	#pragma HLS array_partition variable=layer_2_out factor=15

	#pragma HLS array_partition variable=W3 factor=25 dim=1


	//limit resources to max DSP number of Zybo - do not change
	#pragma HLS ALLOCATION instances=mul limit=80 operation

	read_input:
	for (int i=0; i<N1; i++)
	{
		#pragma HLS pipeline II=1
		xbuf[i] = x[i];
	}

	// Layer 1
	layer_1:
	for(int i=0; i<N1; i++)
	{
		#pragma HLS pipeline II=1
		for(int j=0; j<M1; j++)
		{
			#pragma HLS unroll factor=30
			l_quantized_type last = (i==0) ? (l_quantized_type) 0 : layer_1_out[j];
			quantized_type term = xbuf[i] * W1[i][j];
			layer_1_out[j] = last + term;
		}
	}

	layer_1_act:
	for(int i=0; i<M1; i++)
	{
		#pragma HLS pipeline II=1
		layer_1_out[i] = ReLU(layer_1_out[i]);
	}

	layer_2:
	for (int i = 0; i < M2; i ++)
	{
		l_quantized_type result_0 = 0;
		#pragma HLS pipeline II=1
		for (int j = 0; j < N2; j++)
		{
			#pragma HLS unroll factor=30
			l_quantized_type term_0 = layer_1_out[j] * W2[j][i];

			result_0 += term_0;
		}
		layer_2_out[i] = ReLU(result_0);
	}

	// Layer 3
	layer_3:
	for (int i = 0; i < M3; i ++)
	{
		l_quantized_type result = 0;
		#pragma HLS pipeline II=1
		for (int j = 0; j < N3; j++)
		{
			#pragma HLS unroll factor=50
			l_quantized_type term_0 = layer_2_out[j] * W3[j][i];

			result += term_0;
		}
		y[i] = tanh(result).to_float();
	}
}