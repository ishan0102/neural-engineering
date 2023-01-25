
filteredSignal = ; % bandapass filtered signal 
label = ; % labels of stimulus locations

WSize = ; % window size in s
Olap = ; % overlap percentage

%% Extracting Features over overlapping windows

WSize = floor(WSize*fs);	    % length of each data frame, 30ms
nOlap = floor(Olap*WSize);  % overlap of successive frames, half of WSize
hop = WSize-nOlap;	    % amount to advance for next data frame
nx = length(signal);	            % length of input vector
len = fix((nx - (WSize-hop))/hop);	%length of output vector = total frames

% preallocate outputs for speed
[MAV_feature, VAR_feature, featureLabels] = deal(zeros(1,len));

Rise1 = gettrigger(label,0.5); % gets the starting points of stimulations
Fall1 = gettrigger(-label,-0.5); % gets the ending points of stimulations

for i = 1:len
    segment = filteredSignal(((i-1)*hop+1):((i-1)*hop+WSize));
    MAV_feature(i) = ;
    VAR_feature(i) = ;
    
    % re-build the label vector to match it with the feature vector
    featureLabels(i) = sum(arrayfun(@(t) ((i-1)*hop+1) >= Rise1(t) && ((i-1)*hop+WSize) <= Fall1(t), 1:length(Rise1)));
end

%% Plotting the features
% Note: when plotting the features, scale the featureLabels to the max of
% the feature values for proper visualization


