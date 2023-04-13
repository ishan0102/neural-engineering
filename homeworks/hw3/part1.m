close all;

%% Config Constants
global RUN_START_END;
global TRIAL_START;
global FIXATION;
global LEFT_CUE;
global RIGHT_CUE;
global LEFT_START;
global RIGHT_START;
global LEFT_END_TIMEOUT;
global RIGHT_END_TIMEOUT;
global LEFT_END_HIT;
global RIGHT_END_HIT;


RUN_START_END = 32766;
TRIAL_START = 1000;
FIXATION = 768;
LEFT_CUE = 769;
RIGHT_CUE = 770;
LEFT_START = 7691;
RIGHT_START = 7701;
LEFT_END_TIMEOUT = 7692;
RIGHT_END_TIMEOUT = 7702;
LEFT_END_HIT = 7693;
RIGHT_END_HIT = 7703;

%% Load and Plot Raw Signal
subject1 = load("subj1.mat");
subject2 = load("subj2.mat");
load("ch32Locations.mat");
disp("Load complete");


%% Plot accuracy over session

[accuracy_subj1, timeouts_subj1] = extract_accuracy(subject1.subj1);
idx = 1;
means_subj1 = [];
timeout_mean_subj1 = [];
for i = 1:6
    mean = accuracy_subj1(idx) + accuracy_subj1(idx+1) + accuracy_subj1(idx+2);
    means_subj1(i) = (mean/3);
    timeout_mean = timeouts_subj1(idx) + timeouts_subj1(idx+1) + timeouts_subj1(idx+2);
    timeout_mean_subj1(i) = (timeout_mean/3);
    idx = idx + 3;
end

[accuracy_subj2, timeouts_subj2] = extract_accuracy(subject2.subj2);
idx = 1;
means_subj2 = [];
timeout_mean_subj2 = [];
for i = 1:6
    mean = accuracy_subj2(idx) + accuracy_subj2(idx+1) + accuracy_subj2(idx+2);
    means_subj2(i) = (mean/3);
    timeout_mean = timeouts_subj2(idx) + timeouts_subj2(idx+1) + timeouts_subj2(idx+2);
    timeout_mean_subj2(i) = (timeout_mean/3);
    idx = idx + 3;
end

% Updated style for accuracy plot
figure
hold on;
plot(means_subj1, '-o', 'LineWidth', 2, 'Color', [0, 0.4470, 0.7410], 'MarkerFaceColor', [0, 0.4470, 0.7410], 'MarkerSize', 8);
plot(means_subj2, '-s', 'LineWidth', 2, 'Color', [0.8500, 0.3250, 0.0980], 'MarkerFaceColor', [0.8500, 0.3250, 0.0980], 'MarkerSize', 8);
hold off;
ylim([0 1]);
xlabel('Session', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Accuracy per session', 'FontSize', 12, 'FontWeight', 'bold');
title("Accuracy over sessions", 'FontSize', 14, 'FontWeight', 'bold');
legend("Subject 1", "Subject 2", 'FontSize', 10, 'Location', 'best');
grid on;
ax = gca;
ax.FontSize = 11;
ax.FontWeight = 'bold';
ax.LineWidth = 1.5;
ax.GridLineStyle = '--';
ax.GridAlpha = 0.5;
ax.Box = 'on';


%% Statistical analysis across sessions
extract_analysis(means_subj1, 1);
extract_analysis(means_subj2, 2);
extract_analysis((means_subj1 + means_subj2) / 2, 3);

extract_analysis(timeout_mean_subj1, 4);
extract_analysis(timeout_mean_subj2, 5);
extract_analysis((timeout_mean_subj1 + timeout_mean_subj2) / 2, 6);

%% Statistical analysis comparing sessions
ttest_extraction(accuracy_subj1, 1);
ttest_extraction(accuracy_subj2, 2);
ttest_extraction(timeouts_subj1, 3);
ttest_extraction(timeouts_subj2, 4);


%% Functions 
function [accuracy, timeouts] = extract_accuracy(subj)
    global LEFT_END_TIMEOUT;
    global RIGHT_END_TIMEOUT;
    global LEFT_END_HIT;
    global RIGHT_END_HIT; 

    accuracy =[];
    timeouts = [];
    idx = 1;

    for i = 1:6
        for j = 1:3
            triggers = subj.online(i).run(j).header.triggers.TYP;
            pos = subj.online(i).run(j).header.triggers.POS;
            acc = 0;
            timeout = 0;
            size = 0;
            for l = 1:length(triggers)
                switch triggers(l)
                    case LEFT_END_TIMEOUT
                        size = size + 1;
                        if (pos(l) - pos(l-1) > 3500)
                            timeout = timeout + 1;
                        end
                    case RIGHT_END_TIMEOUT
                        size = size + 1;
                        if (pos(l) - pos(l-1) > 3500)
                            timeout = timeout + 1;
                        end
                    case LEFT_END_HIT
                        acc = acc + 1;
                        size = size + 1;
                    case RIGHT_END_HIT
                        acc = acc + 1;
                        size = size + 1;
                    otherwise 
                        continue;
                end
            end
            accuracy(idx) = acc/size;
            timeouts(idx) = timeout/size;
            idx = idx + 1;
        end
    end
end


function extract_analysis(data, index)
    y = data;
    x = [1 2 3 4 5 6];
    p = polyfit(x, y, 1); % fit a first-degree polynomial to the data
    yfit = polyval(p, x); % predicted values of y based on line of best fit
    r = corrcoef(y, yfit); % correlation coefficient
    rsq = r(1, 2)^2; % R-squared value

    if index == 1
        figure;
        subplot(1, 2, 1);
        hold on;
    elseif index == 4
        subplot(1, 2, 2);
        hold on;
    end

    plot(x, y, 'o-', 'LineWidth', 2, 'MarkerSize', 8);
    xlim([0.8 6.2]);

    if index == 1 || index == 4
        xlabel('Session', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('Percentage', 'FontSize', 12, 'FontWeight', 'bold');
        grid on;
        ylim([0 1]);
        ax = gca;
        ax.FontSize = 11;
        ax.FontWeight = 'bold';
        ax.LineWidth = 1.5;
        ax.GridLineStyle = '--';
        ax.GridAlpha = 0.5;
        ax.Box = 'on';
    end

    if index == 1 || index == 2 || index == 3
        title('Command Delivery Accuracy over Session', 'FontSize', 14, 'FontWeight', 'bold');
    else
        title('Timeout Percentage over Sessions', 'FontSize', 14, 'FontWeight', 'bold');
    end

    if index == 3 || index == 6
        legend(["Subject 1 (R^2 = " + num2str(rsq, "%.4f") + ")", "Subject 2 (R^2 = " + num2str(rsq, "%.4f") + ")", "Both Subjects (R^2 = " + num2str(rsq, "%.4f") + ")"], 'Location', 'Best');
        hold off;
    end
end

function ttest_extraction(data, index)
    p_list = [];
    idx = 4;
    x = [1 2 3 4 5 6];
    for i = 1:6
        if i == 1
            p_list(i) = 0;
        else
            [h, p] = ttest(data(1:3), data(idx:idx + 2));
            p_list(i) = p;
            idx = idx + 3;
        end
    end

    if index == 1
        figure;
        subplot(1, 2, 1);
        hold on;
    elseif index == 3
        subplot(1, 2, 2);
        hold on;
    end

        plot(x, p_list, 'o-', 'LineWidth', 2, 'MarkerSize', 8);

    if index == 1 || index == 3
        xlabel('Session', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('P Value', 'FontSize', 12, 'FontWeight', 'bold');
        ylim([0 1]);
        grid on;
        ax = gca;
        ax.FontSize = 11;
        ax.FontWeight = 'bold';
        ax.LineWidth = 1.5;
        ax.GridLineStyle = '--';
        ax.GridAlpha = 0.5;
        ax.Box = 'on';
    end

    if index == 1 || index == 2
        title('Command Delivery Accuracy Relative to the First Session', 'FontSize', 14, 'FontWeight', 'bold');
    else
        title('Timeout Percentage Relative to the First Session', 'FontSize', 14, 'FontWeight', 'bold');
    end

    if index == 2 || index == 4
        legend(["Accuracy - Subject 1", "Accuracy - Subject 2", "Timeouts - Subject 1", "Timeouts - Subject 2"], 'Location', 'Best');
        hold off;
    end
end