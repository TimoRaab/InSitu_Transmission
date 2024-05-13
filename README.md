# InSitu_Transmission

Files for In-Situ Transmission Spin Coating Setup from the PhD Thesis "In-Situ Characterization of Film Formation in Solution-Processed Solar Cells" from Timo Raab, Universität Konstanz, 2022.


File setup of in-situ Data
v09+

The files are stored binary using the LabView WriteToBinaryFile function. For correct sizing of the arrays the dimension is stored additionally at the beginning of each file. 
For each measurement 4 files are stored:
_meas.spin (stores the real data)
_time.spin (stores the time of each data point (in 10us, standard from spectrometer))
_add.spin (additional data like dark and reference spectra, wavelength axis, start time …)

For using these binary files one has to know exactly how these are stored, as one is only interpreting bytes when reading them. One could open these files with any other program and let it try to interpret these files. If additional informations are stored in the LabView program, the interpretation of the read scripts has to be adjusted accordingly. 


The meas.spin stores each point as an „unsigned int 16“. One can imagine it as a black and white movie, in which spectrum is a picture containing its grey values. The size of the picture are the x and y direction. The length of the movie is frames. 
All of these values are stored at the beginning of each file as an „unsigned integer 32“. Therefore before reading the measurement data, first the 3 dimensions of the movie are read from the file. Afterwards the actual measurement data is read from the file. It is exactly x*y*frames datapoints read.
After reading, all these data is contained in a one dimensional array. This has to be reshaped to a correct 3-dimensional array. 

The time array is in labview a one dimensional array. It is also stored like the data, but only one dimension is written in front of the actual data and therefore has to be read before the data. The size has to be the same as the frames. The time is stored as an uint32 for better resolution and enough range.

The add.spin is the most complicated file, as multiple arrays and values are stored. 
3 dimensional array for the dark-spectrum (uint16)
3 dimensional array for the reference spectrum (uint16)
1 dimensional array for the wavelength (double)
single value for starttime (double)
single value for timeDiff (double)
