clear all
close all
clc

%% Import Data
load('data.mat');

%% Example: Plot the raw signal
signal=Flex.signal;
labels=Flex.trigger;
TRIG = gettrigger(labels,0.5);
TRIGend = gettrigger(-labels,-0.5);

figure('units','normalized','Position',[0.1,0.1,0.7,0.4])
plot((1:length(signal))./fs,zscore(signal));
hold on;
plot((1:length(signal))./fs,zscore(labels),'y');
stem(TRIG./fs,ones(length(TRIG),1)*max(zscore(labels)),'Color','g');
stem(TRIGend./fs,ones(length(TRIG),1)*max(zscore(labels)),'Color','r');
grid on; grid minor;
xlim([0,length(signal)./fs])
xlabel('Time (s)')
ylabel('Amplitude (uV)')
title('Raw VF signal with labels for stimulation periods')

%% Example: PSD estimates
figure('units','normalized','Position',[0.1,0.1,0.5,0.5])
[rows_act,cols_act,values_act] = find(labels>0);
[rows_rest1,cols_rest,values_rest] = find(labels==0);
notOfInterest = signal(rows_rest1);
signalOfInterest=signal(rows_act);
h = spectrum.welch; % creates the Welch spectrum estimator
SOIf=psd(h,signalOfInterest,'Fs',fs); % calculates and plot the one sided PSD
plot(SOIf); % Plot the one-sided PSD. 
temp =get(gca);
temp.Children(1).Color = 'b';

%% Bandpass Filtering

fc1 = ; % first cutoff frequency in Hz 
fc2 = ; % second cutoff frequency in Hz 

% normalize the frequencies
Wp = [fc1 fc2]*2/fs;

% Build a Butterworth bandpass filter of 4th order
% check the "butter" function in matlab

% Filter data of both classes with a non-causal filter
% Hint: use "filtfilt" function in MATLAB
% filteredSignal = ;

%% 



