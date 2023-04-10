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

figure 
hold on;
plot(means_subj1);
hold on
plot(means_subj2);
hold off; 
ylim([0 0.8]);
xlabel('Session');
ylabel('Accuracy per session');
title("Accuracy over sessions");
legend("Subject 1", "Subject 2");


%% Statistical analysis across sessions 

extract_analysis(means_subj1,1);
extract_analysis(means_subj2,2);
extract_analysis((means_subj1 + means_subj2)/2,3);

extract_analysis(timeout_mean_subj1,1);
extract_analysis(timeout_mean_subj2,2);
extract_analysis((timeout_mean_subj1 + timeout_mean_subj2)/2,3);


%% Statistical analysis comparing sessions 

ttest_extraction(accuracy_subj1,1);
ttest_extraction(accuracy_subj2,2);

ttest_extraction(timeouts_subj1,3);
ttest_extraction(timeouts_subj2,4);



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
    rsq = r(1,2)^2; % R-squared value
    disp(rsq);
    
    figure;
    hold on;
    
    lim = [];
    titles = "";
    switch index
        case 1
            lim = [.05 .65];
            titles = "Average Percentage of Timeouts + Statistical Analysis for Subject 1";
        case 2
            lim = [.25 .75];
            titles = "Average Percentage of Timeouts + Statistical Analysis for Subject 2";
        case 3
            lim = [.2 .7];
            titles = "Average Percentage of Timeouts + Statistical Analysis for Both Subjects";
    end 
    
    
    str = "R-squared = " + string(rsq);
    dim = [.2 .5 .3 .3];
    annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on');
    plot(x, y, 'o', x, polyval(p, x), '-');
    ylim(lim);
    xlim([0.8 6.2]);
    xlabel('Session');
    ylabel('Percentage of Timeouts');
    title(titles);
    hold off;

end


function ttest_extraction(data, index)
    p_list = [];
    idx = 4;
    x = [1 2 3 4 5 6];
    for i = 1:6
        if i == 1
            p_list(i) = 0;
        else
            [h, p] = ttest(data(1:3), data(idx:idx+2));
            p_list(i) = p;
            idx = idx + 3;
        end
    end

    lim = [];
    titles = "";
    switch index
        case 1
            lim = [0 1.2];
            titles = "P Value Statistical Analysis of Accuracy for Subject 1";
        case 2
            lim = [0 1.2];
            titles = "P Value Statistical Analysis of Accuracy for Subject 2";
        case 3
            lim = [0 1];
            titles = "P Value Statistical Analysis of Timeout Percentage for Subject 1";
        case 4
            lim = [0 0.4];
            titles = "P Value Statistical Analysis of Timeout Percentage for Subject 2";
        
    end 

    figure 
    hold on;
    plot(x, p_list,'o');
    hold off; 
    ylim(lim);
    xlabel('Session');
    ylabel('P Value');
    title(titles);

end