close all;

%% Config Constants
global RUN_START_END;
global TRIAL_START;
global FIXATION;
global PINCH_CUE;
global POINT_CUE;
global GRASP_CUE;
global PINCH_START;
global POINT_START;
global GRASP_START;
global PINCH_END;
global POINT_END;
global GRASP_END;

RUN_START_END = 32766;
TRIAL_START = 1000;
FIXATION = 768;
PINCH_CUE = 100;
POINT_CUE = 200;
GRASP_CUE = 300;
PINCH_START = 101;
POINT_START = 201;
GRASP_START = 301;
PINCH_END = 102;
POINT_END = 202;
GRASP_END = 302;

%% Load and Plot Raw Signal
subject1 = load("subject1.mat");
subject2 = load("subject2.mat");

plot_run_trial(subject1.subject, false, 1, 1);

%% Plot PSD of Trial Segments
plot_psd(subject1.subject, false, 1, 1, "FlxDist");

%% Filter All Runs for Both Subjects
subject1.subject.filtered_emg = filter_all_runs(subject1.subject);
subject2.subject.filtered_emg = filter_all_runs(subject2.subject);

%%
test = subject2.subject.filtered_emg;
test2 = test(1);
disp(subject2.subject.filtered_emg(1));
%% Plot Filtered Signal
plot_run_trial(subject1.subject, true, 1, 1);
plot_psd(subject1.subject, true, 1, 1, "FlxDist");

%% Extract the Task Periods and Classes
subject1.subject.task_periods = extract_task_periods(subject1.subject);
subject1.subject.classes = extract_classes(subject1.subject);
subject2.subject.task_periods = extract_task_periods(subject2.subject);
subject2.subject.classes = extract_classes(subject2.subject);

disp(size(subject2.subject.task_periods{1}));

%% Functions
function label = get_event_label(event_no)
    global TRIAL_START;
    global FIXATION;
    global PINCH_CUE;
    global POINT_CUE;
    global GRASP_CUE;
    global PINCH_START;
    global POINT_START;
    global GRASP_START;
    global PINCH_END;
    global POINT_END;
    global GRASP_END;
    
    switch event_no
        case TRIAL_START
            label = "Trial Start";
        case FIXATION
            label = "Fixation";
        case {PINCH_CUE, POINT_CUE, GRASP_CUE}
            label = "Cue";
        case {PINCH_START, POINT_START, GRASP_START}
            label = "Task Start";
        case {PINCH_END, POINT_END, GRASP_END}
            label = "Task End";
        otherwise
            disp(event_no == POINT_CUE);
    end
end

function plot_run_trial(subject, filtered, run_num, trial_num)
    global TRIAL_START;
    
    run = subject.run(run_num);
    events = subject.run(run_num).header.EVENT;
    trial_start_events = find(events.TYP == TRIAL_START, trial_num);
    trial_start_event_idx = trial_start_events(end);
    trial_start_idx = events.POS(trial_start_event_idx);
    trial_end_idx = events.POS(trial_start_event_idx + 4);
    
    if filtered
        trial_signal = subject.filtered_emg(run_num);
        trial_signal = trial_signal{1,1};
        trial_signal = trial_signal(trial_start_idx:trial_end_idx, :);
    else
        trial_signal = run.emg(trial_start_idx:trial_end_idx, :);
    end
    
    n = trial_end_idx - trial_start_idx + 1;
    t = n / run.header.fs;
    
    figure;
    for i = 1:4
        subplot(4,1,i);
        plot(linspace(0, 1, n)*t, trial_signal(:,i));
        % Plot event lines
        for j = 1:length(run.header.EVENT.TYP)
            event_type = run.header.EVENT.TYP(j);
            event_pos = run.header.EVENT.POS(j);
            if event_pos >= trial_start_idx
                if event_pos > trial_end_idx
                    break
                end
                
                xline((event_pos - trial_start_idx) / run.header.fs, '--', get_event_label(event_type));
            end
        end
        title("Run " + run_num + " Trial " + trial_num + " " + run.header.Label(i));
        xlabel("Time (s)");
    end
    
    if filtered
        file_suffix = " Filtered";
    else
        file_suffix = "";
    end
    
    saveas(gcf, "part"+run_num+".png");
end

function plot_psd(subject, filtered, run_num, trial_num, sensor)
    global TRIAL_START;
    
    run = subject.run(run_num);
    events = subject.run(run_num).header.EVENT;
    trial_start_events = find(events.TYP == TRIAL_START, trial_num);
    trial_start_event_idx = trial_start_events(end);
    trial_start_idx = events.POS(trial_start_event_idx);
    trial_fixation_idx = events.POS(trial_start_event_idx + 1);
    trial_cue_idx = events.POS(trial_start_event_idx + 2);
    trial_task_start_idx = events.POS(trial_start_event_idx + 3);
    trial_task_end_idx = events.POS(trial_start_event_idx + 4);
    
    % Separate into the sections
    sensor_idx = find(run.header.Label == sensor);
    
    if filtered
        sensor_signal = subject.filtered_emg(run_num);
        sensor_signal = sensor_signal{1,1};
        sensor_signal = sensor_signal(:, sensor_idx);
    else
        sensor_signal = run.emg(:, sensor_idx);
    end
    
    rest_period = sensor_signal(trial_start_idx:trial_fixation_idx);
    fixation_period = sensor_signal(trial_fixation_idx:trial_cue_idx);
    cue_period = sensor_signal(trial_cue_idx:trial_task_start_idx);
    task_period = sensor_signal(trial_task_start_idx:trial_task_end_idx);
    
    % Plot PSDs
    figure;
    
    h = spectrum.welch;
    rest_psd = psd(h, rest_period, 'Fs', run.header.fs);
    fixation_psd = psd(h, fixation_period, 'Fs', run.header.fs);
    cue_psd = psd(h, cue_period, 'Fs', run.header.fs);
    task_psd = psd(h, task_period, 'Fs', run.header.fs);
    
    plot(rest_psd); hold on;
    plot(fixation_psd); hold on;
    plot(cue_psd); hold on;
    plot(task_psd); hold on;
    
    temp = get(gca);
    temp.Children(1).Color = 'red';
    temp.Children(2).Color = 'green';
    temp.Children(3).Color = 'blue';
    temp.Children(4).Color = 'yellow';
    
    legend("Rest", "Fixation", "Cue", "Task");
    
    if filtered
        file_suffix = " Filtered";
    else
        file_suffix = "";
    end
    
    saveas(gcf, "PSD"+run_num+".png");
end

function filtered_emg = filter_all_runs(subject)
    % Cutoff frequencies determined from visual inspection of PSDs
    fc1 = 50;
    fc2 = 100;
    
    n = length(subject.run);
    filtered_emg = cell(n, 1);
    
    for i = 1:n
        run = subject.run(i);
        Wp = [fc1 fc2] * 2 / run.header.fs;
        [b, a] = butter(2, Wp);
        filtered_emg{i} = filtfilt(b, a, run.emg);
    end
end

function task_periods = extract_task_periods(subject)
    % gets the task period and returns a 180 cell array with each data x 4 
    global TRIAL_START;
    
    task_periods = {};
    idx = 1;
    
    for i = 1:length(subject.filtered_emg)
        run = subject.run(i);
        trial_start_idx = find(run.header.EVENT.TYP == TRIAL_START);
        trial_start_pos = run.header.EVENT.POS(trial_start_idx);
        task_start_pos = run.header.EVENT.POS(trial_start_idx + 3);
        trial_end_pos = run.header.EVENT.POS(trial_start_idx + 4);

        trial_signal = subject.filtered_emg(i);
        trial_signal = trial_signal{1,1};
        trial_signal = trial_signal(trial_start_idx(1):trial_end_pos(end), :);

        for j = 1:length(trial_start_idx) 
            % disp(size(trial_signal));
            curr_task_period = trial_signal(task_start_pos(j):trial_end_pos(j)-1, :);
            task_periods{idx} = curr_task_period;
            % disp(size(curr_task_period));
            idx = idx + 1;
        end
    end
%    task_periods = task_periods(1:idx-1); 
end

function classes = extract_classes(subject)
    global TRIAL_START;
    global PINCH_CUE;
    global GRASP_CUE;
    global POINT_CUE;
    global FIXATION;
    
    classes = strings(1,1000);
    % disp(classes);
    idx = 1;
    
    for i = 1:length(subject.filtered_emg)
        run = subject.run(i);
        trial_start_idx = (run.header.EVENT.TYP == TRIAL_START);
        trial_start_pos = run.header.EVENT.POS(trial_start_idx);
        trial_cue_idx = run.header.EVENT.TYP(trial_start_idx + 2);
        task_start_pos = run.header.EVENT.POS(trial_start_idx + 3);
        trial_end_pos = run.header.EVENT.POS(trial_start_idx + 4);
        label = "test";
        classes(idx) = label;
        for j = 1:length(run.header.EVENT.TYP)
            switch run.header.EVENT.TYP(j)
                case PINCH_CUE
                    label = "PINCH";
                    classes(idx) = label;
                    idx = idx + 1;
                case POINT_CUE
                    label = "POINT";
                    classes(idx) = label;
                    idx = idx + 1;
                case GRASP_CUE
                    label = "GRASP";
                    classes(idx) = label;
                    idx = idx + 1;
                otherwise
                    continue;
            end
        end
        
    end
    classes = classes(1:idx-1);
end


