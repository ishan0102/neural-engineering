clear
close all
clc

load('vf_filtered.mat')
load('data.mat')

%% Create features
filteredSignal = filtered_signal; % bandapass filtered signal 
label = VF.trigger; % labels of stimulus locations

WSize = 0.1; % window size in s
Olap = 0; % overlap percentage

%% Extracting Features over overlapping windows
WSize = floor(WSize*fs);	    % length of each data frame, 30ms
nOlap = floor(Olap*WSize);  % overlap of successive frames, half of WSize
hop = WSize-nOlap;	    % amount to advance for next data frame
nx = length(filteredSignal);	            % length of input vector
len = fix((nx-(WSize-hop))/hop);	%length of output vector = total frames

% preallocate outputs for speed
[MAV_feature, VAR_feature, featureLabels] = deal(zeros(1,len));

Rise1 = gettrigger(label,0.5); % gets the starting points of stimulations
Fall1 = gettrigger(-label,-0.5); % gets the ending points of stimulations

for i = 1:len
    segment = filteredSignal(((i-1)*hop+1):((i-1)*hop+WSize));
    N = length(segment);
    signal_mean = mean(segment);

    for j = 1:N
        MAV_feature(i) = MAV_feature(i) + (abs(segment(j)) / N);
        VAR_feature(i) = VAR_feature(i) + ((segment(j)-signal_mean)^2 / N);
    end
    
    % re-build the label vector to match it with the feature vector
    featureLabels(i) = sum(arrayfun(@(t) ((i-1)*hop+1) >= Rise1(t) && ((i-1)*hop+WSize) <= Fall1(t), 1:length(Rise1)));
end

%% Plotting the features
% Note: when plotting the features, scale the featureLabels to the max of
% the feature values for proper visualization
figure()
plot(featureLabels * max(MAV_feature)); hold on;
plot(MAV_feature); hold on;

figure()
plot(featureLabels * max(VAR_feature)); hold on;
plot(VAR_feature); hold on;


