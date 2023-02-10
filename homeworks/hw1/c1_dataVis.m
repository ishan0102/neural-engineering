clear
close all
clc

%% Import Data
load('data.mat');

%% Plot the VF, Flex, and Pinch signals
figure('units','normalized','Position',[0.1,0.1,0.7,0.4])

%%% VF
subplot(3,1,1)

vf_signal=VF.signal;
vf_labels=VF.trigger;
TRIG = gettrigger(vf_labels,0.5);
TRIGend = gettrigger(-vf_labels,-0.5);

plot((1:length(vf_signal))./fs,zscore(vf_signal));
hold on;
plot((1:length(vf_signal))./fs,zscore(vf_labels),'y');
stem(TRIG./fs,ones(length(TRIG),1)*max(zscore(vf_labels)),'Color','g');
stem(TRIGend./fs,ones(length(TRIG),1)*max(zscore(vf_labels)),'Color','r');
grid on; grid minor;
xlim([0,length(vf_signal)./fs])
xlabel('Time (s)')
ylabel('Amplitude (uV)')
title('Raw VF signal with labels for stimulation periods')

%%% Flex
subplot(3,1,2)

flex_signal=Flex.signal;
flex_labels=Flex.trigger;
TRIG = gettrigger(flex_labels,0.5);
TRIGend = gettrigger(-flex_labels,-0.5);

plot((1:length(flex_signal))./fs,zscore(flex_signal));
hold on;
plot((1:length(flex_signal))./fs,zscore(flex_labels),'y');
stem(TRIG./fs,ones(length(TRIG),1)*max(zscore(flex_labels)),'Color','g');
stem(TRIGend./fs,ones(length(TRIG),1)*max(zscore(flex_labels)),'Color','r');
grid on; grid minor;
xlim([0,length(flex_signal)./fs])
xlabel('Time (s)')
ylabel('Amplitude (uV)')
title('Raw Flex signal with labels for stimulation periods')

%%% Pinch
subplot(3,1,3)

pinch_signal=Pinch.signal;
pinch_labels=Pinch.trigger;
TRIG = gettrigger(pinch_labels,0.5);
TRIGend = gettrigger(-pinch_labels,-0.5);

plot((1:length(pinch_signal))./fs,zscore(pinch_signal));
hold on;
plot((1:length(pinch_signal))./fs,zscore(pinch_labels),'y');
stem(TRIG./fs,ones(length(TRIG),1)*max(zscore(pinch_labels)),'Color','g');
stem(TRIGend./fs,ones(length(TRIG),1)*max(zscore(pinch_labels)),'Color','r');
grid on; grid minor;
xlim([0,length(pinch_signal)./fs])
xlabel('Time (s)')
ylabel('Amplitude (uV)')
title('Raw Pinch signal with labels for stimulation periods')

%% Plot the PSD estimates
figure('units','normalized','Position',[0.1,0.1,0.5,0.5])

%%% VF
[rows_act,cols_act,values_act] = find(vf_labels>0);
[rows_rest1,cols_rest,values_rest] = find(vf_labels==0);

notOfInterest=vf_signal(rows_rest1);
signalOfInterest=vf_signal(rows_act);
h = spectrum.welch; % creates the Welch spectrum estimator
SOIf = psd(h,signalOfInterest,'Fs',fs); % calculates and plot the one sided PSD
SNOIf = psd(h,notOfInterest,'Fs',fs); % calculates and plots the rest period
plot(SOIf); % Plot the one-sided PSD.
hold on;
plot(SNOIf);
hold on;

%%% Flex
[rows_act,cols_act,values_act] = find(flex_labels>0);
[rows_rest1,cols_rest,values_rest] = find(flex_labels==0);

notOfInterest=flex_signal(rows_rest1);
signalOfInterest=flex_signal(rows_act);
h = spectrum.welch; % creates the Welch spectrum estimator
SOIf = psd(h,signalOfInterest,'Fs',fs); % calculates and plot the one sided PSD
SNOIf = psd(h,notOfInterest,'Fs',fs); % calculates and plots the rest period
plot(SOIf); % Plot the one-sided PSD.
hold on;
plot(SNOIf);
hold on;

%%% Pinch
[rows_act,cols_act,values_act] = find(pinch_labels>0);
[rows_rest1,cols_rest,values_rest] = find(pinch_labels==0);

notOfInterest=pinch_signal(rows_rest1);
signalOfInterest=pinch_signal(rows_act);
h = spectrum.welch; % creates the Welch spectrum estimator
SOIf = psd(h,signalOfInterest,'Fs',fs); % calculates and plot the one sided PSD
SNOIf = psd(h,notOfInterest,'Fs',fs); % calculates and plots the rest period
plot(SOIf); % Plot the one-sided PSD.
hold on;
plot(SNOIf)
hold on;

legend("VF", "VF Rest", "Flex", "Flex Rest", "Pinch", "Pinch Rest");
temp=get(gca);
temp.Children(6).Color='r';
temp.Children(5).Color='r';
temp.Children(5).LineStyle=':';
temp.Children(4).Color='g';
temp.Children(3).Color='g';
temp.Children(3).LineStyle=':';
temp.Children(2).Color='b';
temp.Children(1).Color='b';
temp.Children(1).LineStyle=':';

%% Perform bandpass filtering with a Butterworth filter
figure('units','normalized','Position',[0.1,0.1,0.7,0.4])

fc1 = 800; % first cutoff frequency in Hz 
fc2 = 2200; % second cutoff frequency in Hz 

% normalize the frequencies
Wp = [fc1 fc2]*2/fs;

% Build a Butterworth bandpass filter of 4th order
% check the "butter" function in matlab
[b, a] = butter(2, Wp, 'bandpass');

% Filter data of both classes with a non-causal filter
% Hint: use "filtfilt" function in MATLAB
filtered_signal = filtfilt(b, a, vf_signal);

% Plot the raw VF signal
subplot(2,1,1)
plot(vf_signal)
xlabel('Time (s)')
ylabel('Amplitude (uV)')
title('Raw VF signal')

% Plot the filtered VF signal
subplot(2,1,2)
plot(filtered_signal)
xlabel('Time (s)')
ylabel('Amplitude (uV)')
title('Filtered VF signal')

%% Plot the PSD for the filtered signal
figure('units','normalized','Position',[0.1,0.1,0.5,0.5])

%%% VF
[rows_act,cols_act,values_act] = find(vf_labels>0);
[rows_rest1,cols_rest,values_rest] = find(vf_labels==0);

notOfInterest=filtered_signal(rows_rest1);
signalOfInterest=filtered_signal(rows_act);
h = spectrum.welch; % creates the Welch spectrum estimator
SOIf=psd(h,signalOfInterest,'Fs',fs); % calculates and plot the one sided PSD
plot(SOIf); % Plot the one-sided PSD.

%% Write all filtered signals to a file
vf_filtered = filtfilt(b, a, vf_signal);
flex_filtered = filtfilt(b, a, flex_signal);
pinch_filtered = filtfilt(b, a, pinch_signal);
save('filtered.mat', 'vf_filtered', 'flex_filtered', 'pinch_filtered')