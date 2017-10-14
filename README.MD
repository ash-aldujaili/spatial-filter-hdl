# Image Processing Spatial Filters on FPGA

## What is this ?
This repository hosts an implementation of a generic spatial (window, neighbourhood) image filter with the following configurations:

	1. window size: 7x7, 5x5, 3x3
	
	2. configurable filter coefficients (fixed point representation normalized to sum to 1)
	
	3. configurable filter circuit (multiply add circuts : FPGA fabric, DSP, transposed form, direct form)
	
Along with testbench files and data files organized as follows:

	a. src: the filter verilog source files.
	
	b. test_io : data files (images and filter coefficints in their text files representation)
	
	c. testbench: verilog testbench files. Some are for specific submodules, others are for the filter as a whole.
	
	d. utils (MATLAB scripts to generate to and from image text representations)

## A note on testing	
For testing purposes, I have provided a testbench `filter_tb2.v` which reads an image in a txt format (a text file recording the pixle value in integer format one pixel per linee.g., `ImagText.txt`) and 
a filter coefficinet file (a text file recording the coefficients in integer format one coefficient per line, e.g., `FilCof.txt` for edge detection). It outputs the filtered image in a txt format (e.g., `TextImage.txt`). 
A utility MATLAB script is provided in utils to generate the txt file from an input image and to generate an image from a txt format.

## A note on the filter configuration
The filter can be configured with different settings (refer to the paper). `filter_tb2.v` lists---in the comments---some of these configurations

## A note on the filter coefficients
The mathematical computation of the filter are done in a signed 0.14 fixed point format. So you have to set the filter values accordingly.
Examples:
	a. Smoothing filter: 1/(window_size^2) is the coefficient value per pixel. So for 7x7 window and with signed 0.14 fixed point representation, the pixels coefficients have to be set
		to int(1/49 * 2^14). See `filter_tb2.v`.
	b. In general: let MAX be the maximum value possible from a weighted combination of sum(a'coefficient) where a is a zero-one vector(this suggests MIN=-MAX). Then the coefficient values
		have to be set such that:
			~~~
			coefficient_value_for_filter = coefficient_value_from_text_file * 2^14/MAX
			~~~
		

## Citations

If you write a scientific paper describing research that made use of this code, please cite the following paper:

@Article{ash-fpga,
  Title                    = {High Throughput Image Filters on FPGAs},
  Author                   = {Al-Dujaili, Abdullah and Fahmy, Suhaib A.},
  Journal                  = {??},
  Year                     = {2016}
}
