%% PSD features
% 7 sessions * 3 runs * 20 trials = 420 trials 
% 448 features per trial

psd_features_subj1 = feature_extraction(subject1.subj1);
psd_features_subj2 = feature_extraction(subject2.subj2);
disp("Updated psd feature data structure");

%% example features

disp(size(psd_features_subj1{7}{1}));
disp(size(psd_features_subj1{5}{2}));

%% Compute Fisher scores 2.2

fisher_scores_subj1 = {};
fisher_scores_subj2 = {};
for i = 1:7
    fisher_scores_subj1{end+1} = calculate_fisher_score(psd_features_subj1{i});
    fisher_scores_subj2{end+1} = calculate_fisher_score(psd_features_subj2{i});
end

channel_names = subject1.subj1.offline.run(1).header.chLabels;
band_names = [4,6,8,10,12,14,16,18,20,22,24,26,28,30];
[sorted_values, sorted_indices] = sort(fisher_scores_subj2{7}(:),'descend');
for i = 1:10
    [band, channel] = ind2sub([14,32], sorted_indices(i));
    disp(i + ": values: " + sorted_values(i) + " channel: " + channel_names{channel} + " band: "+ band_names(band));
end

%%
% disp((subject1.subj1.online(1).run(2).header.chLabels));
% disp(size(subject1.subj1.online(1).run(2).header.chLabels));
% disp((subject1.subj1.offline.run(1).header.chLabels));


%% Fisher scores across sessions 2.3
load("ch32Locations.mat");

% Create a figure with 7 subplots arranged in a 3 x 3 grid
fisher_score_sum = {};
figure
for i = 1:7
    scores = fisher_scores_subj1{i};
    sum_score = sum(scores);
    fisher_score_sum{end+1} = (sum_score);  
    
    % Select the appropriate subplot based on the index i
    subplot(3,3,i);
    hold on;
    title("Session "+i);
    topoplot(fisher_score_sum{end}, ch32Locations, 'maplimits', 'maxmin');
    hold off;
end
text(1,-0.7,'Summed Fisher Score for Subject 1 on Sessions 1-7','HorizontalAlignment','center','FontSize',9,'FontWeight','bold','Interpreter','none');

fisher_score_sum = {};
figure
for i = 1:7
    scores = fisher_scores_subj2{i};
    sum_score = sum(scores);
    fisher_score_sum{end+1} = (sum_score);  
    
    % Select the appropriate subplot based on the index i
    subplot(3,3,i);
    hold on;
    title("Session "+i);
    topoplot(fisher_score_sum{end}, ch32Locations, 'maplimits', 'maxmin');
    hold off;
end
text(1,-0.7,'Summed Fisher Score for Subject 2 on Sessions 1-7','HorizontalAlignment','center','FontSize',9,'FontWeight','bold','Interpreter','none');

%% Highest Fisher score 2.4

[sorted_values, sorted_indices] = sort(fisher_scores_subj1{7}(:),'descend');
[channel_subj1, band_subj1] =ind2sub([14,32], sorted_indices(1));
[sorted_values, sorted_indices] = sort(fisher_scores_subj2{7}(:),'descend');
[channel_subj2, band_subj2] = ind2sub([14,32], sorted_indices(1));

subj1_session_fisher = [];
subj2_session_fisher = [];
for i = 1:7
    scores = fisher_scores_subj1{i};
    subj1_session_fisher(end+1) = scores(channel_subj1, band_subj1);
    subj2_session_fisher(end+1) = scores(channel_subj2, band_subj2);  
end

    
%% Functions 

function psd_features = feature_extraction(subject)
    % returns an array of 7 cells first 6 are offline runs last is online
    % first cell is left second cell is right 
    % cells are 14 x 32 x 30 where 30 is 10 trials from 3 runs 
    %
    % ex: (psd_features_subj1{7}{1}) - left 30 trials from session 7
    % psd_features_subj1{5}{2}) - right 30 trials from session 5
    
    psd_features = {};
    % extract online features
    for i = 1:6
        session_features = cell(1,2);
        left = [];
        right = [];
        for j = 1:3
            eeg = subject.online(i).run(j).eeg;
            typ = subject.online(i).run(j).header.triggers.TYP;
            pos = subject.online(i).run(j).header.triggers.POS;
            f = extract_task_periods(eeg, typ, pos);
            for s = 1:20
                if f{s}{2} == 1
                    left = cat(3, left, f{s}{1}); 
                end
                if f{s}{2} == 2
                    right = cat(3, right, f{s}{1}); 
                end
            end
            %session_features{j} = f;
        end
        session_features{1} = left;
        session_features{2} = right;
        psd_features{i} = session_features;
    end

    % extract offline features 
    session_features = cell(1,2);
    left = [];
    right = [];
    for i = 1:3
        eeg = subject.offline.run(i).eeg;
        typ = subject.offline.run(i).header.triggers.TYP;
        pos = subject.offline.run(i).header.triggers.POS;
        % session_features{i} 
        f = extract_task_periods(eeg, typ, pos);
        for s = 1:20
            if f{s}{2} == 1
                left = cat(3, left, f{s}{1}); 
            end
            if f{s}{2} == 2
                right = cat(3, right, f{s}{1}); 
            end
        end
    end
    session_features{1} = left;
    session_features{2} = right;
    psd_features{end+1} = session_features;
end


function task_periods = extract_task_periods(eeg, typ, pos)
    % returns back an array of cells with feature matrix as first input and
    % label as second (1 = left, 2 = right label values)

    global LEFT_START;
    global RIGHT_START;
    
    task_periods = {};
    labels = {}; 
    idx = 1;
    for i = 1:length(typ)
        switch typ(i)
            case LEFT_START
                feat = cell(1,2);
                start_pos = pos(i);
                end_pos = pos(i+1);
                segment = eeg(start_pos:end_pos, :);
                features = calculate_psd(segment);
    
                feat{1} = features;
                feat{2} = 1;

                task_periods{idx} = feat;
                idx = idx + 1;

            case RIGHT_START
                feat = cell(1,2);
                start_pos = pos(i);
                end_pos = pos(i+1);
                segment = eeg(start_pos:end_pos, :);
                features = calculate_psd(segment);

                feat{1} = features;
                feat{2} = 2;

                task_periods{idx} = feat;
                idx = idx + 1;       
        end
    end
    
%    task_periods = task_periods(1:idx-1); 
end


function psd_seg = calculate_psd(segment)
    % Calculate the PSD for the given segment
    % Frequency range: [4-30] Hz with a resolution of 2Hz
    freq_range = 4:2:30;
    [pxx, f] = pwelch(segment, [], [], [4:2:30], 512); % assuming fs = 250 Hz
    psd_seg = 10 * log10(pxx);
end


function fisher_scores = calculate_fisher_score(session_data)
    fisher_scores = [];
    
    left_data = session_data{1};
    std_matrix_left = std(left_data, 0, 3);
    mean_matrix_left = [];
    for i = 1:14
        for j = 1:32
            sum_depth = sum(left_data(i,j,1:30));
            mean_matrix_left(i,j) = (sum_depth)/30;
        end
    end

    right_data = session_data{2};
    std_matrix_right = std(right_data, 0, 3);
    mean_matrix_right = [];
    for i = 1:14
        for j = 1:32
            sum_depth = sum(right_data(i,j,1:30));
            mean_matrix_right(i,j) = (sum_depth)/30;
        end
    end

    fisher_scores = abs(mean_matrix_left - mean_matrix_right) ./ sqrt(std_matrix_left.^2 + std_matrix_right.^2);

end
