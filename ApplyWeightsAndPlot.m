%This program applies calibrated weights to the USRP data in order to
%observe the effects of the random phase offset on the daughter board.
%Use CalibrateWeights.m on one boresight capture of the array and run this
%program on another boresight capture to observe the change in the phase
%offset.

clear, clc, close all
format short, format compact

Window = (100:500); %Range over which data is plotted.

%Read USRP data from file
%X_t = ReadF32(["RF0" "RF1" "RF2" "RF3"]).';
X_t = ReadF32Vector("RF",4).';

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
X_t_new = diag(Weights)*X_t;

%Plot Data with weights applied
figure(2)
plot(Window,real(X_t_new(:,Window)))
title('Weighted RF Data')
xlabel('samples')
ylabel('Real Component')
legend('RF0','RF1','RF2','RF3')
ylim([-1.5 1.5])
grid on

%Calculate Phase Error
PhaseError = angle(X_t_new(1,:).*conj(X_t_new));
PhaseNoiseSTD = std(PhaseError(4,:))

%Plot Phase Error
figure(3)
plot(1:length(X_t),PhaseError*180/pi)
xlim([1 length(X_t)])
title('Phase Error Relative to RF0')
xlabel('samples')
ylabel('Phase Error [Degrees]')
legend('RF0','RF1','RF2','RF3')
grid on