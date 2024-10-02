%This program takes N310 data with unsynchronized
%boards and uses signal processing techniques to
%bring the two boards in phase. The program then uses
%adaptive beamforming to separate up to 3 signals.

clear, clc, close all
format short, format compact

RFDataFile = "RF2GHz";
CalibrationDataFile = "Weights2GHz";
samp_rate = 1E6; %capture sample rate
d = 0.5; %Wavelengths
Window = (100:550); %Range over which data is plotted.

%Read USRP data from file
%X_t = ReadF32(["RF0" "RF1" "RF2" "RF3"]).';
X_t = ReadF32Vector(RFDataFile,4).';

%Read Weights from File
Weights = ReadF32(CalibrationDataFile);

%Plot real part of each channel
figure(1)
plot(Window/samp_rate,real(X_t(:,Window)))
title('Raw RF Data')
xlabel('Time [s]')
ylabel('Real Component')
legend('RF0','RF1','RF2','RF3')
xlim([Window(1)/samp_rate Window(end)/samp_rate]);
grid on

%Apply Calibrated Weights
X_t = diag(Weights)*X_t;

%Plot real part of each channel
figure(2)
plot(Window/samp_rate,real(X_t(:,Window)))
title('Calibrated RF Data')
xlabel('Time [s]')
ylabel('Real Component')
legend('RF0','RF1','RF2','RF3')
xlim([Window(1)/samp_rate Window(end)/samp_rate]);
%ylim([-1.5 1.5])
grid on

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
figure(3)
plot(Window/samp_rate,real(X_t(:,Window)))
title('Phase Corrected RF DATA')
xlabel('Time [s]')
ylabel('Real Component')
legend('RF0','RF1','RF2','RF3')
xlim([Window(1)/samp_rate Window(end)/samp_rate]);
%ylim([-1.5 1.5])
grid on

%Compute new cross-correlation matrix
Rxx = X_t*X_t'/length(X_t(1,:));

%Compute noise subspace
[U EigVals] = eig(Rxx);
Eigvals = diag(EigVals)';
[SortedEigVals Indexes] = sort(Eigvals);
U_n = U(:, Indexes(1)); %Create Noise Subspace

%Compute MUSIC psuedospectrum
Theta = -90:0.1:90;
for n = 1:length(Theta);
    Arrivalvec = exp(1j*[0:3]'*2*pi*d*sind(Theta(n)));
    Pmusic(n) = 20*log(abs(1./(Arrivalvec'*U_n*U_n'*Arrivalvec)));
end
Pmusic = Pmusic-max(Pmusic);

%Compute AOA of signals
[Peaks AOA] = findpeaks(Pmusic,Theta);

%Plot MUSIC pseudospectrum
figure(4)
plot(Theta,Pmusic)
title('MUSIC Psuedospectrum')
xlim([-90 90])
xline(AOA, 'r--')
grid on

%Isolate the signal coming from each direction
for n = 1:length(AOA)
    %Find LCMV weights to null the other two signals
    a = exp(1j*[0:3].'*2*pi*d*sind(AOA)); %arrival matrix
    D = zeros(length(AOA),1);
    D(n) = 1;
    LCMVWeights = inv(Rxx)*a*(a.'*inv(Rxx)*a)^-1*D;

    %Apply LCMV Weights
    Y_t(n,:) = LCMVWeights.'*X_t;
    
    %Plot I-Channel
    figure(4+n)
    subplot(2,1,1)
    plot(Window/samp_rate,real(Y_t(n,Window)))
    title(['I-Channel at ' num2str(AOA(n)) ' Degrees'])
    xlabel('Time [s]')
    xlim([Window(1)/samp_rate Window(end)/samp_rate]);
    grid on

    %Plot Q-Channel
    subplot(2,1,2)
    plot(Window/samp_rate,imag(Y_t(n,Window)), 'm')
    title(['Q-Channel at ' num2str(AOA(n)) ' Degrees'])
    xlabel('Time [s]')
    xlim([Window(1)/samp_rate Window(end)/samp_rate]);
    grid on
end