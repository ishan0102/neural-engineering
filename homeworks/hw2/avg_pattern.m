%% find avg patterns 
% pinch 1 
% point 2
% grasp 3

mav_periods = extract_mav_periods(subject1.subject);
avg = average_mav(subject1.subject, mav_periods);

% pinch
pinch_mav_avg = avg{1};
n = length(pinch_mav_avg);
t = n / 512;
trials = [3, 5, 10, 15, 29];
legend_labels = cell(1, length(trials) + 1);

figure;
hold on;
for i = 1:length(trials)
    index = trials(i);
    test = padarray(mav_periods{index}, [n-length(mav_periods{index}), 0], 0, 'post');
    plot(linspace(0, 1, n)*t, test(:, 3));
    legend_labels{i} = sprintf('Trial %d', index);
end
plot(linspace(0, 1, n)*t, pinch_mav_avg(:, 3));
legend_labels{end} = 'Average Trial';
hold off;
title("MAV average – Pinch and 5 random trials");
xlim([0, 2.5]);
xlabel("Time (s)");
legend(legend_labels)

% point
point_mav_avg = avg{2};
n = length(point_mav_avg);
t = n / 512;

figure;
hold on;
for i = 1:length(trials)
    index = trials(i);
    test = padarray(mav_periods{index}, [n-length(mav_periods{index}), 0], 0, 'post');
    plot(linspace(0, 1, n)*t, test(:, 3));
end
plot(linspace(0, 1, n)*t, point_mav_avg(:, 3));
hold off;
title("MAV average – Point and 5 random trials");
xlim([0, 2.5]);
xlabel("Time (s)");
legend(legend_labels)

% grasp
grasp_mav_avg = avg{3};
n = length(grasp_mav_avg);
t = n / 512;

figure;
hold on;
for i = 1:length(trials)
    index = trials(i);
    test = padarray(mav_periods{index}, [n-length(mav_periods{index}), 0], 0, 'post');
    plot(linspace(0, 1, n)*t, test(:, 3));
end
plot(linspace(0, 1, n)*t, grasp_mav_avg(:, 3));
hold off;
title("MAV average — Grasp and 5 random trials");
xlim([0, 2.5]);
xlabel("Time (s)");
legend(legend_labels)

%% function

function mav_periods = extract_mav_periods(subject)
    % gets the task period and finds MAV 
    global TRIAL_START;
    
    mav_periods = {};
    idx = 1;
    
    for i = 1:length(subject.filtered_emg)
        run = subject.run(i);
        trial_start_idx = find(run.header.EVENT.TYP == TRIAL_START);
        trial_start_pos = run.header.EVENT.POS(trial_start_idx);
        task_start_pos = run.header.EVENT.POS(trial_start_idx + 3);
        trial_end_pos = run.header.EVENT.POS(trial_start_idx + 4);

        trial_signal = subject.filtered_emg(i);
        trial_signal = trial_signal{1,1};
        trial_signal = abs(trial_signal(trial_start_idx(1):trial_end_pos(end), :));
        trial_signal = lowpass(trial_signal,5, run.header.fs);

        for j = 1:length(trial_start_idx) 
            % disp(size(trial_signal));
            curr_task_period = trial_signal(task_start_pos(j):trial_end_pos(j)-1, :);
            mav_periods{idx} = curr_task_period;
            % disp(size(curr_task_period));
            idx = idx + 1;
        end
    end
end

% find the average mav for each movement
function avg_mav = average_mav(subject, mav_periods)
    tasks = mav_periods;
    avg_mav = cell(1,3);
    sum = zeros(1297,4);
    pinch_avg = zeros(1297,4);
    point_avg = zeros(1297,4);
    grasp_avg = zeros(1297,4);
    for i = 1:length(tasks)
        new_mav = padarray(mav_periods{i},[1297-length(mav_periods{i}),0],0,'post');
        label = subject.classes(i);
        switch label
            case "PINCH"
                pinch_avg = pinch_avg + new_mav;
            case "POINT"    
                point_avg = point_avg + new_mav;
            case "GRASP"
                grasp_avg = grasp_avg + + new_mav;
        end
    end
    pinch_avg = pinch_avg/60;
    point_avg = point_avg/60;
    grasp_avg = grasp_avg/60;
    avg_mav{1} = pinch_avg;
    avg_mav{2} = point_avg;
    avg_mav{3} = grasp_avg;
end
