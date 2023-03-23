%% feature extraction

% pinch = 1, point = 2, grasp = 3
subject_features_subject1 = features(subject1.subject);
subject_features_subject2 = features(subject2.subject);
sensors = string({'ExtProx' 'ExtDist' 'FlxProx' 'FlxDist'});

MAV = (subject_features_subject1{1}{1});
WL = (subject_features_subject1{1}{2});
class_labels = cell2mat(subject_features_subject1{1}{3});

% disp(MAV(class_labels==1));
% disp((subject_features_subject1{1}{3}{121}));

MAV_class1 = MAV(class_labels==1);
WL_class1 = WL(class_labels==1);
MAV_class2 = MAV(class_labels==2);
WL_class2 = WL(class_labels==2);
MAV_class2 = MAV(class_labels==3);
WL_class2 = WL(class_labels==3);

% Plot feature space for subject 1
figure;
sgtitle('Subject 1');
for i = 1:4
    MAV = (subject_features_subject1{i}{1});
    WL = (subject_features_subject1{i}{2});
    class_labels = cell2mat(subject_features_subject1{i}{3});

    MAV_class1 = MAV(class_labels==1);
    WL_class1 = WL(class_labels==1);
    MAV_class2 = MAV(class_labels==2);
    WL_class2 = WL(class_labels==2);
    MAV_class3 = MAV(class_labels==3);
    WL_class3 = WL(class_labels==3);

    subplot(2, 2, i);
    scatter(cell2mat(MAV_class1(1)), cell2mat(WL_class1(1)), 'r', 'filled', 'Marker', 's');
    hold on;
    scatter(cell2mat(MAV_class2(1)), cell2mat(WL_class2(1)), 'g', 'filled', 'Marker', '^');
    scatter(cell2mat(MAV_class3(1)), cell2mat(WL_class3(1)), 'b', 'filled');
    xlabel('MAV');
    ylabel('WL');
    title(sensors(i) + ' feature space - WL vs. MAV');
    legend("Pinch", "Point", "Grasp");
end

% Plot feature space for subject 2
figure;
sgtitle('Subject 2');
for i = 1:4
    MAV = (subject_features_subject2{i}{1});
    WL = (subject_features_subject2{i}{2});
    class_labels = cell2mat(subject_features_subject2{i}{3});

    MAV_class1 = MAV(class_labels==1);
    WL_class1 = WL(class_labels==1);
    MAV_class2 = MAV(class_labels==2);
    WL_class2 = WL(class_labels==2);
    MAV_class3 = MAV(class_labels==3);
    WL_class3 = WL(class_labels==3);

    subplot(2, 2, i);
    scatter(cell2mat(MAV_class1(1)), cell2mat(WL_class1(1)), 'r', 'filled', 'Marker', 's');
    hold on;
    scatter(cell2mat(MAV_class2(1)), cell2mat(WL_class2(1)), 'g', 'filled', 'Marker', '^');
    scatter(cell2mat(MAV_class3(1)), cell2mat(WL_class3(1)), 'b', 'filled');
    xlabel('MAV');
    ylabel('WL');
    title(sensors(i) + ' feature space - WL vs. MAV');
    legend("Pinch", "Point", "Grasp");
end

%% Functions 

function subject_features = features(subject)
    % compute features for given subject

    tasks = subject.task_periods;
    run = subject.run;
    subject_features = cell(1,4);

    for s = 1:4
        labels = {};
        MAV = {};
        WL = {};
        grasp = {};
        pinch = {};
        point = {};
        for i = 1:length(tasks)
            signal = (tasks{i}(:,s));
            [MAV_features, WL_features, feature_label] = extract_features(signal, run(s).header.fs, subject.classes(i), .150, .33);
            MAV{end+1} = MAV_features;
            WL{end+1} = WL_features;
            labels{end+1} = feature_label;
        end
        feat = cell(1,3);
        feat{1} = MAV;
        feat{2} = WL;
        feat{3} = labels;
        subject_features{s} = feat;

    end
    
end


function [MAV_features, WL_features, feature_label] = extract_features(signal, fs, label, w, o)
    Olap = o; % overlap percentage
    wSize = floor(w*fs);	    % length of each data frame, 30ms
    nOlap = floor(Olap*wSize);
    hop1 = wSize - nOlap;
    nx = length(signal);
    len = fix((nx - (wSize-hop1))/hop1);	%length of output vector = total frames
    
    [MAV_features,WL_features] = deal(zeros(1,len));
    feature_label = 0;

    switch label
        case "PINCH"
            feature_label = 1;
        case "POINT"
            feature_label = 2;
        case "GRASP"
            feature_label = 3;
    end
    
    for i = 1:len
        segment = signal(((i-1)*hop1+1):((i-1)*hop1+wSize));
        MAV_features(i) = sum(abs(segment))/size(segment,1);
        WL_features(i) = sum(abs(diff(segment)));
        
        % re-build the label vector to match it with the feature vector
    end
    
end

function TRIG = gettrigger(s,TH,rfp)
    if nargin<2
	    TH = (max(s)+min(s))/2;
    end
    if nargin<3
	    rfp = 0; 
    end 	
    
    TRIG = find(diff(sign(s-TH))>0)+1;
    % perform check of trigger points
    
    if (rfp<=0), return; end 
    
    % refractory period 
    k0=1;
    k1=2;
    while k1<length(TRIG)
	    T0 = TRIG(k0);
	    T1 = TRIG(k1);
	    if (T1-T0)<rfp
		    TRIG(k1)=NaN;
	    else
		    k0 = k1; 
	    end
	    k1 = k1+1;
    end
    TRIG=TRIG(~isnan(TRIG));
end