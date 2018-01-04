This repository contains, to the extent possible, the scripts and data necessary to reproduce the results in our paper. It also contains the final figures.

Matlab scripts are self-describing with comments at the top as well as throughout.

Each stndataYYYY-YYYY.mat file contains temperature (T), specific humidity (q), dewpoint, and wet-bulb temperature (WBT) hourly values for MJJASO in a given 2-year period. Each of these cell arrays (finaldataXXX) is of dimensions 175x1, where 175 corresponds to the number of stations. The dimensions of each cell are 8832x1, with 8832 being the number of hours in two consecutive MJJASO periods.

The names and locations of the 175 stations analyzed are listed in the stnmetadata.mat file.

With any questions, please email me at cr2630@columbia.edu.
