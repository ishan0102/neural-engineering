%% Cross-validation
% Combine subject data and features
subjects_data = {subject1, subject2};

num_subjects = 2;
num_classes = 3;
num_runs = 6;

reorg_subject_features_subject1 = reorganize_features(subject_features_subject1, num_runs);
reorg_subject_features_subject2 = reorganize_features(subject_features_subject2, num_runs);
subject_features = {reorg_subject_features_subject1, reorg_subject_features_subject2};

chosen_classifiers = cell(1, num_subjects);

% Run-wise cross-validation for each subject
for subject = 1:num_subjects
    accuracies_linear = zeros(1, num_runs);
    accuracies_quadratic = zeros(1, num_runs);
    
    for run = 1:num_runs
        % Combine data from all other runs for training
        % Training data and labels
        training_data = [];
        training_labels = [];
        
        for train_run = 1:num_runs
            display(train_run);
            if train_run ~= run
                training_data_mav = subject_features{subject}{1}';
                training_data_mav = training_data_mav(train_run);
                training_data_mav = cell2mat(training_data_mav{1}(1));
                
                training_data_wl = subject_features{subject}{1}';
                training_data_wl = training_data_wl(train_run);
                training_data_wl = cell2mat(training_data_wl{1}(2));
                training_data = [training_data; training_data_mav, training_data_wl];
                
                training_labels_run = subject_features{subject}{1}';
                training_labels_run = training_labels_run(train_run);
                training_labels_run = cell2mat(training_labels_run{1}(3));
                training_labels = [training_labels; training_labels_run(:)];
            end
        end
        
        % Test data and labels
        test_data_mav = subject_features{subject}{1}';
        test_data_mav = test_data_mav(run);
        test_data_mav = cell2mat(test_data_mav{1}(1));
        
        test_data_wl = subject_features{subject}{1}';
        test_data_wl = test_data_wl(run);
        test_data_wl = cell2mat(test_data_wl{1}(2));
        
        test_data = [test_data_mav, test_data_wl];
        
        test_labels = cell2mat(subject_features{subject}{1}');
        test_labels = test_labels(run);
        test_labels = cell2mat(test_labels{1}(3));
        
        % Linear LDA
        linear_lda = fitcdiscr(training_data, training_labels, 'DiscrimType', 'linear');
        linear_pred = predict(linear_lda, test_data);
        accuracies_linear(run) = sum(linear_pred == test_labels) / length(test_labels);
        
        % Quadratic LDA
        quadratic_lda = fitcdiscr(training_data, training_labels, 'DiscrimType', 'quadratic');
        quadratic_pred = predict(quadratic_lda, test_data);
        accuracies_quadratic(run) = sum(quadratic_pred == test_labels) / length(test_labels);
    end
    
    % Calculate average accuracy for linear and quadratic LDA
    avg_linear_accuracy = mean(accuracies_linear);
    avg_quadratic_accuracy = mean(accuracies_quadratic);
    
    % Compare and choose the best classifier
    if avg_linear_accuracy > avg_quadratic_accuracy
        fprintf('Subject %d: Linear LDA is better with an average accuracy of %.2f\n', subject, avg_linear_accuracy);
        chosen_classifiers{subject} = fitcdiscr(training_data, training_labels, 'DiscrimType', 'linear');
    else
        fprintf('Subject %d: Quadratic LDA is better with an average accuracy of %.2f\n', subject, avg_quadratic_accuracy);
        chosen_classifiers{subject} = fitcdiscr(training_data, training_labels, 'DiscrimType', 'quadratic');
    end
end

%% Test the classifiers on the sixth run for each subject
for subject = 1:num_subjects
    test_data_mav = cell2mat(subject_features{subject}{6}{1}');
    test_data_wl = cell2mat(subject_features{subject}{6}{2}');
    test_data = [test_data_mav, test_data_wl];
    
    test_labels = cell2mat(subject_features{subject}{6}{3}');
    
    test_pred = predict(chosen_classifiers{subject}, test_data);
    test_accuracy = sum(test_pred == test_labels) / length(test_labels);
    
    fprintf('Subject %d: Test accuracy on the sixth run is %.2f\n', subject, test_accuracy);
end

%% Transfer decoders: Test the decoder of each subject on the sixth run of the other subject
for subject = 1:num_subjects
    other_subject = mod(subject, 2) + 1;
    
    test_data_mav = cell2mat(subject_features{other_subject}{6}{1}');
    test_data_wl = cell2mat(subject_features{other_subject}{6}{2}');
    test_data = [test_data_mav, test_data_wl];
    
    test_labels = cell2mat(subject_features{other_subject}{6}{3}');
    
    test_pred = predict(chosen_classifiers{subject}, test_data);
    test_accuracy = sum(test_pred == test_labels) / length(test_labels);
    
    fprintf('Subject %d classifier: Test accuracy on the sixth run of subject %d is %.2f\n', subject, other_subject, test_accuracy);
end

%% Reorganize features
function reorganized_subject_features = reorganize_features(subject_features, num_runs)
    reorganized_subject_features = cell(num_runs, 1);
    
    for r = 1:num_runs
        run_data = cell(1, 3);
        MAV_data = [];
        WL_data = [];
        labels_data = [];
        
        for s = 1:4
            MAV_data = [MAV_data; cell2mat(subject_features{s}{1}(r:num_runs:end)')];
            WL_data = [WL_data; cell2mat(subject_features{s}{2}(r:num_runs:end)')];
            labels_data = [labels_data; cell2mat(subject_features{s}{3}(r:num_runs:end)')];
        end
        
        run_data{1} = MAV_data;
        run_data{2} = WL_data;
        run_data{3} = labels_data;
        
        reorganized_subject_features{r} = run_data;
    end
end
