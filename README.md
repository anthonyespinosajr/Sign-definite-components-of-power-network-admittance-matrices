# Sign definite components of power network admittance matrices

This repository contains the MATLAB scripts, data, and documentation necessary to produce the results referenceed in the paper "Sign definite components of power network admittance matrices."

The IEEE PES test feeders whose associated public data are used in these scripts include:
34-Node Test Feeder
37-Node Test Feeder
European Low Voltage Test Feeder

The files containing the data for each of the test feeders was originally acquired from the IEEE PES website:
https://cmte.ieee.org/pes-testfeeders/resources/



# Description
Descriptions are provided for each of the MATLAB scripts included in this repository.

# `Main.m`
This script uses functions of the MATLAB classes implemented by the other scripts to compute the results referenced in the paper.

# `SignDefiniteComputer.m`
This script implements the SignDefiniteComputer class, which can be used to generate the network admittance matrix (NAM) from phase admittance matrices. The SignDefiniteComputer class is also capable of computing and returning the eigenvalues of the NAM components, booleans indicating the sign definiteness of the NAM components and the complex symmetry of the NAM, and printing these results in a readable format. 

# `SequenceSignDefiniteComputer.m`
This script, which inherits the SignDefiniteComputer class, implements the SequenceSignDefiniteComputer class, which can be used to generate the network admittance matrix (NAM) from sequence parameters that specify the phase admittance matrices for a network's edges. The SequenceSignDefiniteComputer class primarily implements the computation of corresponding phase admittance matrices from given sequence parameters.

# `BusFeeder34.m`
This script, which inherits the SignDefiniteComputer class, implements the BusFeeder34 class, which specifies the phase admittance matrices for the 34-Node Test Feeder, based on the given data from the IEEE PES.

# `BusFeeder37.m`
This script, which inherits the SignDefiniteComputer class, implements the BusFeeder37 class, which specifies the phase admittance matrices for the 37-Node Test Feeder, based on the given data from the IEEE PES.

# `EuropeanLVTF.m`
This script, which inherits the SequenceSignDefiniteComputer class, implements the EuropeanLVTF class, which specifies the phase admittance matrices for the European Low Voltage Test Feeder, based on the given data from the IEEE PES.
