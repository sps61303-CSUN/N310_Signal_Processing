%This program takes N310 data with unsynchronized
%boards and uses signal processing techniques to
%bring the two boards in phase. The program then uses
%adaptive beamforming to separate up to 3 signals.

clear, clc, close all
format short, format compact

d = 0.5; %Wavelengths
Window = (100:400); %Range over which data is plotted.

%Read USRP data from file
X_t = ReadF32(["RF0" "RF1" "RF2" "RF3"]).';

%Read Weights from File
Weights = ReadF32("CalibratedWeights");

%Plot real part of each channel
figure(1)
plot(Window,real(X_t(:,Window)))
title('Raw RF Data')
xlabel('samples')
ylabel('Real Component')
legend('RF0','RF1','RF2','RF3')
grid on

%Apply Calibrated Weights
X_t = diag(Weights)*X_t;

%Compute cross-correlation matrix
Rxx = X_t*X_t'/length(X_t(1,:));

%Take the phase of the crosscorrelation between RF0 and RF1 and average
%it with the phase of the crosscorrelation between RF2 and RF3.
AdjacentPhase = (phase(Rxx(2,1))+phase(Rxx(4,3)))/2;

%Compute the phase Error
PhaseError = phase(Rxx(3,2))-AdjacentPhase; %Radians

%Apply Corrective Phase Weights
X_t = diag([1 1 exp(-1j*PhaseError) exp(-1j*PhaseError)])*X_t;

%Plot real part of each channel with phase correction
figure(2)
plot(Window,real(X_t(:,Window)))
title('Phase Corrected RF DATA')
xlabel('samples')
ylabel('Real Component')
legend('RF0','RF1','RF2','RF3')
grid on

%Compute new cross-correlation matrix
Rxx = X_t*X_t'/length(X_t(1,:));

%Compute noise subspace
[U Eigen] = eig(Rxx);
U_n = U(:,1); %noise subspace

%Compute MUSIC psuedospectrum
Theta = -90:0.1:90;
for n = 1:length(Theta);
    Arrivalvec = exp(1j*[0:3]'*2*pi*d*sind(Theta(n)));
    Pmusic(n) = 20*log(abs(1./(Arrivalvec'*U_n*U_n'*Arrivalvec)));
end
Pmusic = Pmusic-max(Pmusic);

%Plot MUSIC pseudospectrum
figure(3)
plot(Theta,Pmusic)
title('MUSIC Psuedospectrum')
grid on

%Compute AOA of signals
[Peaks AOA] = findpeaks(Pmusic,Theta);

%Isolate the signal coming from each direction
for n = 1:length(AOA)
    %Find LCMV weights to null the other two signals
    C = exp(-1j*[0:3]'*2*pi*d*sind(AOA));
    D = zeros(3,1);
    D(n) = 1;
    LCMVWeights = inv(Rxx)*C*(C'*inv(Rxx)*C)^-1*D;

    %Apply LCMV Weights
    Y_t(n,:) = LCMVWeights.'*X_t;
    
    %Plot I-Channel
    figure(3+n)
    subplot(2,1,1)
    plot(Window,real(Y_t(n,Window)))
    title('I-Channel')
    grid on

    %Plot Q-Channel
    subplot(2,1,2)
    plot(Window,imag(Y_t(n,Window)), 'm')
    title('Q-Channel')
    grid on
end
