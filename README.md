# Electronic-Systems---Compass-Heading
A repository for the Electronic Systems course AA 25-26. 
This project implements the design for a compass heading. This is achieved by computing the atan2 result of 2 given C2 8-bit fixed point numbers.
The atan2 function has been implemented piecewise starting from a LUT for an atan function

## Warning for Vivado's Implementation
Due to the fact that the "ieee.fixed_point" package is only available for VHDL2008 Vivado projects, in order to properly load this project the "compass_heading.vhd" file type must be set as VHDL2008 before performing a synthesis
