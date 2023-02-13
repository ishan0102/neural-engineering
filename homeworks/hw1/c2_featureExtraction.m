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

%% Plot MAV vs. VAR
figure()
[MAV_feature, VAR_feature, featureLabels] = getFeatures(0.1, 0, vf_filtered, VF.trigger);
subplot(3,2,1)
plot(featureLabels * max(MAV_feature)); hold on;
plot(MAV_feature);
title("VF MAV Features")
subplot(3,2,2)
plot(featureLabels * max(VAR_feature)); hold on;
plot(VAR_feature);
title("VF VAR Features")

[MAV_feature, VAR_feature, featureLabels] = getFeatures(0.1, 0, flex_filtered, Flex.trigger);
subplot(3,2,3)
plot(featureLabels * max(MAV_feature)); hold on;
plot(MAV_feature);
title("Flex MAV Features")
subplot(3,2,4)
plot(featureLabels * max(VAR_feature)); hold on;
plot(VAR_feature);
title("Flex VAR Features")

[MAV_feature, VAR_feature, featureLabels] = getFeatures(0.1, 0, pinch_filtered, Pinch.trigger);
subplot(3,2,5)
plot(featureLabels * max(MAV_feature)); hold on;
plot(MAV_feature);
title("Pinch MAV Features")
subplot(3,2,6)
plot(featureLabels * max(VAR_feature)); hold on;
plot(VAR_feature);
title("Pinch VAR Features")

%% Determining the SNR
[MAV_feature_vf, VAR_feature_vf, featureLabels_vf] = getFeatures(0.1, 0, vf_filtered, VF.trigger);
MAV_action = MAV_feature_vf(featureLabels_vf == 1);
MAV_rest = MAV_feature_vf(featureLabels_vf == 0);
snr_vf_mav = 20 * log10(mean(MAV_action) / mean(MAV_rest));
VAR_action = VAR_feature_vf(featureLabels_vf == 1);
VAR_rest = VAR_feature_vf(featureLabels_vf == 0);
snr_vf_var = 20 * log10(mean(VAR_action) / mean(VAR_rest));

[MAV_feature_flex, VAR_feature_flex, featureLabels_flex] = getFeatures(0.1, 0, flex_filtered, Flex.trigger);
MAV_action = MAV_feature_flex(featureLabels_flex == 1);
MAV_rest = MAV_feature_flex(featureLabels_flex == 0);
snr_flex_mav = 20 * log10(mean(MAV_action) / mean(MAV_rest));
VAR_action = VAR_feature_flex(featureLabels_flex == 1);
VAR_rest = VAR_feature_flex(featureLabels_flex == 0);
snr_flex_var = 20 * log10(mean(VAR_action) / mean(VAR_rest));

[MAV_feature_pinch, VAR_feature_pinch, featureLabels_pinch] = getFeatures(0.1, 0, pinch_filtered, Pinch.trigger);
MAV_action = MAV_feature_pinch(featureLabels_pinch == 1);
MAV_rest = MAV_feature_pinch(featureLabels_pinch == 0);
snr_pinch_mav = 20 * log10(mean(MAV_action) / mean(MAV_rest));
VAR_action = VAR_feature_pinch(featureLabels_pinch == 1);
VAR_rest = VAR_feature_pinch(featureLabels_pinch == 0);
snr_pinch_var = 20 * log10(mean(VAR_action) / mean(VAR_rest));

%% Write features to a file
save('features.mat', 'MAV_feature_vf', 'VAR_feature_vf', 'featureLabels_vf', ...
    'MAV_feature_flex', 'VAR_feature_flex', 'featureLabels_flex', ...
    'MAV_feature_pinch', 'VAR_feature_pinch', 'featureLabels_pinch')

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