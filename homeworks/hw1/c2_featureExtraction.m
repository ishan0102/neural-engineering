clear
close all
clc

load('data.mat')
load('filtered.mat')

%% Plotting the features
% Note: when plotting the features, scale the featureLabels to the max of
% the feature values for proper visualization
windows = [0.05, 0.1, 0.3];
olaps = [0, 0.25, 0.75];
makeGrids(windows, olaps, vf_filtered, VF.trigger);

%% Determining the SNR
[MAV_feature, VAR_feature, featureLabels] = getFeatures(0.1, 0, vf_filtered, VF.trigger);
MAV_action = MAV_feature(featureLabels == 1);
MAV_rest = MAV_feature(featureLabels == 0);
vf_snr = 20 * log10(mean(MAV_action) / mean(MAV_rest));

[MAV_feature, VAR_feature, featureLabels] = getFeatures(0.1, 0, flex_filtered, Flex.trigger);
MAV_action = MAV_feature(featureLabels == 1);
MAV_rest = MAV_feature(featureLabels == 0);
flex_snr = 20 * log10(mean(MAV_action) / mean(MAV_rest));

[MAV_feature, VAR_feature, featureLabels] = getFeatures(0.1, 0, pinch_filtered, Pinch.trigger);
MAV_action = MAV_feature(featureLabels == 1);
MAV_rest = MAV_feature(featureLabels == 0);
pinch_snr = 20 * log10(mean(MAV_action) / mean(MAV_rest));

%% Create 3x3 grids
function makeGrids(windows, olaps, filtered_signal, filtered_labels)
    for fig = 1:2
        figure(fig)
        for i = 1:length(windows)
            for j = 1:length(olaps)
                [MAV_feature, VAR_feature, featureLabels] = getFeatures(windows(i), olaps(j), filtered_signal, filtered_labels);
                subplot(3, 3, 3*(i-1)+j)
                if fig == 1
                    plot(featureLabels * max(MAV_feature)); hold on;
                    plot(MAV_feature);
                    title("WSize: " + windows(i) + ", Olap: " + olaps(j))
                else
                    plot(featureLabels * max(VAR_feature)); hold on;
                    plot(VAR_feature);
                    title("WSize: " + windows(i) + ", Olap: " + olaps(j))
                end
            end
        end
    end
end

%% Create features
function [MAV_feature, VAR_feature, featureLabels] = getFeatures(WSize, Olap, filtered_signal, filtered_labels)
    load('data.mat', 'fs');
    filteredSignal = filtered_signal; % bandapass filtered signal 
    label = filtered_labels; % labels of stimulus locations
    
    % Extracting Features over overlapping windows
    % WSize: window size in s
    % Olap: overlap percentage
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
end