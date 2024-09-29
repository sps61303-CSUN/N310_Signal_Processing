%Run this on a known signal at boresight to find weights that
%calibrate the system. The phase offset on the daughter board
%is not accounted for.

clear, clc, close all
format short, format compact

%Read USRP data from file
X_t = ReadF32(["RF0" "RF1" "RF2" "RF3"]).';

%Create Sensor Cross Corellation Matrix Rxx
Rxx = X_t*X_t'/length(X_t(1,:))

%Find weights that cause the variance of each channel to be 1.
MagWeights = 1./diag(Rxx).^0.5

%Find weights that lock the phase from RF1 to RF0.
PhaseWeights = [1; abs(Rxx(2,1))./Rxx(2,1)];

%Find weights that lock the phase from RF3 to RF2.
PhaseWeights = [PhaseWeights; 1; abs(Rxx(4,3))./Rxx(4,3)]

%Combine Magnitude and Phase Weights.
Weights = MagWeights.*PhaseWeights

%Write Weights to File
WriteF32(Weights, "CalibratedWeights")