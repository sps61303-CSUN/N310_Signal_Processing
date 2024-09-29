%This program creates four files containing the
%simulated output of the N310. Two interference signals
%and one message signal are applied at different angles.
%The random phase offset on the daughter board is simulated.
%The error due to lack of calibration is also simulated.

clear, clc, close all
format short, format compact

N = 4; %number of elements
d = 0.5; %wavelengths between elements
p = 1E7; %number of samples
ThetaSignal = 20; %degrees
ThetaInt = [-20 45]; %degrees
P_signal = 1E0; %signal power
P_int = 1E3; %interference power
P_noise = 1E-3; %noise power

%Generate random QPSK message signal
T = 20;
M_t = randi(2,1,p/T)*2-3 + 1j*randi(2,1,p/T)*2-3j;
M_t = kron(M_t,ones(1,T))*sqrt(P_signal);

%Gaussian noise interference signals
I_t = normrnd(0,sqrt(P_int),length(ThetaInt),p)/sqrt(2)+1j*normrnd(0,sqrt(P_int),length(ThetaInt),p)/sqrt(2);

%Uncorrelated Gaussian noise
N_t = normrnd(0,sqrt(P_noise),4,p)/sqrt(2)+1j*normrnd(0,sqrt(P_noise),4,p)/sqrt(2);

%Generate Arrival Matrix
A = exp(1j*[0:(N-1)]'*2*pi*d*sind([ThetaSignal ThetaInt]));

%Create Sensor Matrix
X_t = A*[M_t;I_t] + N_t;

%Read Calibrated Weights from file
Weights = ReadF32("CalibratedWeights");

%Apply inverse of calibrated weights
X_t = diag(1./Weights)*X_t;

%Introduce random phase offset on last 2 channels
PhaseOffset = exp(1j*rand*2*pi);
X_t = diag([1 1 PhaseOffset PhaseOffset])*X_t;

% %Introduce phase noise on last 2 channels
% PhaseNoise = exp(j*normrnd(0,0.0131,1,p));
% X_t([3 4],:) = X_t([3 4],:).*[PhaseNoise; PhaseNoise];

%Write to file in complex float32 format
WriteF32(X_t.', ["RF0" "RF1" "RF2" "RF3"])
