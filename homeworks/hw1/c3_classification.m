clear
close all
clc

load('features.mat')
MAVClass1 = MAV_feature_vf;
MAVClass2 = MAV_feature_flex;
VARClass1 = VAR_feature_vf;
VARClass2 = VAR_feature_flex;
TriggerClass1 = featureLabels_vf;
TriggerClass2 = featureLabels_flex;

%%
% Inputs: 
% --------
% MAVClass1: the MAV features of the VF case (stimulus and rest features)
% MAVClass2: the MAV features of the Flex case (stimulus and rest features)
% VARClass1: the VAR features of the VF case (stimulus and rest features)
% VARClass2: the VAR features of the Flex case (stimulus and rest features)
% TriggerClass1: labels for VF features (stimulus or rest label)
% TriggerClass2: labels for Flex features (stimulus or rest label)

% Build the datasets
MAV_class1 = MAVClass1(find(TriggerClass1==1));
MAV_rest1 = MAVClass1(find(TriggerClass1==0));

VAR_class1 = VARClass1(find(TriggerClass1==1));
VAR_rest1 = VARClass1(find(TriggerClass1==0));

MAV_class2 = MAVClass2(find(TriggerClass2==1));
MAV_rest2 = MAVClass2(find(TriggerClass2==0));

VAR_class2 = VARClass2(find(TriggerClass2==1));
VAR_rest2 = VARClass2(find(TriggerClass2==0));

% Concantenate the rest classes
MAV_rest = [MAV_rest1 MAV_rest2];
VAR_rest = [VAR_rest1 VAR_rest2];


%%
% Class1 vs Rest dataset
MAV_Data_Class1vsRest = [MAV_class1 MAV_rest];
MAV_Labels_Class1vsRest = [ones(1,length(MAV_class1)) 2*ones(1,length(MAV_rest))];

VAR_Data_Class1vsRest = [VAR_class1 VAR_rest];
VAR_Labels_Class1vsRest = MAV_Labels_Class1vsRest;

% Class2 vs Rest dataset
MAV_Data_Class2vsRest = [MAV_class2 MAV_rest];
MAV_Labels_Class2vsRest = [ones(1,length(MAV_class2)) 2*ones(1,length(MAV_rest))];

VAR_Data_Class2vsRest = [VAR_class2 VAR_rest];
VAR_Labels_Class2vsRest = MAV_Labels_Class2vsRest;

% Class1 vs Class2 dataset
MAV_Data_Class1vsClass2 = [MAV_class1 MAV_class2];
MAV_Labels_Class1vsClass2 = [ones(1,length(MAV_class1)) 2*ones(1,length(MAV_class2))];

VAR_Data_Class1vsClass2 = [VAR_class1 VAR_class2];
VAR_Labels_Class1vsClass2 = MAV_Labels_Class1vsClass2;

%%
% Both feature datasets
MAVVAR_Data_Class1vsRest = [MAV_Data_Class1vsRest; VAR_Data_Class1vsRest];
MAVVAR_Labels_Class1vsRest = MAV_Labels_Class1vsRest;

MAVVAR_Data_Class2vsRest = [MAV_Data_Class2vsRest; VAR_Data_Class2vsRest];
MAVVAR_Labels_Class2vsRest = MAV_Labels_Class2vsRest;

MAVVAR_Data_Class1vsClass2 = [MAV_Data_Class1vsClass2; VAR_Data_Class1vsClass2];
MAVVAR_Labels_Class1vsClass2 = MAV_Labels_Class1vsClass2;

%%
% Classify all combinations (training set)
k = 10; % for k-fold cross validation
c1 = cvpartition(length(MAV_Labels_Class1vsRest),'KFold',k);
c2 = cvpartition(length(VAR_Labels_Class1vsRest),'KFold',k);
c3 = cvpartition(length(MAVVAR_Labels_Class1vsRest),'KFold',k);
c4 = cvpartition(length(MAV_Labels_Class2vsRest),'KFold',k);
c5 = cvpartition(length(VAR_Labels_Class2vsRest),'KFold',k);
c6 = cvpartition(length(MAVVAR_Labels_Class2vsRest),'KFold',k);
c7 = cvpartition(length(MAV_Labels_Class1vsClass2),'KFold',k);
c8 = cvpartition(length(VAR_Labels_Class1vsClass2),'KFold',k);
c9 = cvpartition(length(MAVVAR_Labels_Class1vsClass2),'KFold',k);

% Repeat the following for i=1:k, and average performance metrics across all iterations
TstAcc_MAV_C1rest_avg = 0;
TstAcc_VAR_C1rest_avg = 0;
TstAcc_MAVVAR_C1rest_avg = 0;
TstAcc_MAV_C2rest_avg = 0;
TstAcc_VAR_C2rest_avg = 0;
TstAcc_MAVVAR_C2rest_avg = 0;
TstAcc_MAV_C1C2_avg = 0;
TstAcc_VAR_C1C2_avg = 0;
TstAcc_MAVVAR_C1C2_avg = 0;
for i=1:k
    % Class1 vs Rest
    [TstMAVFC1Rest TstMAVErrC1Rest] = classify(MAV_Data_Class1vsRest(c1.test(i))',MAV_Data_Class1vsRest(c1.training(i))',MAV_Labels_Class1vsRest(c1.training(i)));
    [TstCM_MAV_C1rest dum1 TstAcc_MAV_C1rest dum2] = confusion(MAV_Labels_Class1vsRest(c1.test(i)), TstMAVFC1Rest);

    [TstVARFC1Rest TstVARErrC1Rest] = classify(VAR_Data_Class1vsRest(c2.test(i))',VAR_Data_Class1vsRest(c2.training(i))',VAR_Labels_Class1vsRest(c2.training(i)));
    [TstCM_VAR_C1rest dum1 TstAcc_VAR_C1rest dum2] = confusion(VAR_Labels_Class1vsRest(c2.test(i)), TstVARFC1Rest);

    [TstMAVVARFC1Rest TstMAVVARErrC1Rest] = classify(MAVVAR_Data_Class1vsRest(:,c3.test(i))',MAVVAR_Data_Class1vsRest(:,c3.training(i))',MAVVAR_Labels_Class1vsRest(c3.training(i)));
    [TstCM_MAVVAR_C1rest dum1 TstAcc_MAVVAR_C1rest dum2] = confusion(MAVVAR_Labels_Class1vsRest(c3.test(i)), TstMAVVARFC1Rest);

    % Class2 vs Rest
    [TstMAVFC2Rest TstMAVErrC2Rest] = classify(MAV_Data_Class2vsRest(c4.test(i))',MAV_Data_Class2vsRest(c4.training(i))',MAV_Labels_Class2vsRest(c4.training(i)));
    [TstCM_MAV_C2rest dum1 TstAcc_MAV_C2rest dum2] = confusion(MAV_Labels_Class2vsRest(c4.test(i)), TstMAVFC2Rest);

    [TstVARFC2Rest TstVARErrC2Rest] = classify(VAR_Data_Class2vsRest(c5.test(i))',VAR_Data_Class2vsRest(c5.training(i))',VAR_Labels_Class2vsRest(c5.training(i)));
    [TstCM_VAR_C2rest dum1 TstAcc_VAR_C2rest dum2] = confusion(VAR_Labels_Class2vsRest(c5.test(i)), TstVARFC2Rest);

    [TstMAVVARFC2Rest TstMAVVARErrC2Rest] = classify(MAVVAR_Data_Class2vsRest(:,c6.test(i))',MAVVAR_Data_Class2vsRest(:,c6.training(i))',MAVVAR_Labels_Class2vsRest(c6.training(i)));
    [TstCM_MAVVAR_C2rest dum1 TstAcc_MAVVAR_C2rest dum2] = confusion(MAVVAR_Labels_Class2vsRest(c6.test(i)), TstMAVVARFC2Rest);

    % Class1 vs Class2
    [TstMAVFC1C2 TstMAVErrC1C2] = classify(MAV_Data_Class1vsClass2(c7.test(i))',MAV_Data_Class1vsClass2(c7.training(i))',MAV_Labels_Class1vsClass2(c7.training(i)));
    [TstCM_MAV_C1C2 dum1 TstAcc_MAV_C1C2 dum2] = confusion(MAV_Labels_Class1vsClass2(c7.test(i)), TstMAVFC1C2);

    [TstVARFC1C2 TstVARErrC1C2] = classify(VAR_Data_Class1vsClass2(c8.test(i))',VAR_Data_Class1vsClass2(c8.training(i))',VAR_Labels_Class1vsClass2(c8.training(i)));
    [TstCM_VAR_C1C2 dum1 TstAcc_VAR_C1C2 dum2] = confusion(VAR_Labels_Class1vsClass2(c8.test(i)), TstVARFC1C2);

    [TstMAVVARFC1C2 TstMAVVARErrC1C2] = classify(MAVVAR_Data_Class1vsClass2(:,c9.test(i))',MAVVAR_Data_Class1vsClass2(:,c9.training(i))',MAVVAR_Labels_Class1vsClass2(c9.training(i)));
    [TstCM_MAVVAR_C1C2 dum1 TstAcc_MAVVAR_C1C2 dum2] = confusion(MAVVAR_Labels_Class1vsClass2(c9.test(i)), TstMAVVARFC1C2);

    % Average out the performance metrics
    TstAcc_MAV_C1rest_avg = TstAcc_MAV_C1rest_avg + TstAcc_MAV_C1rest / k;
    TstAcc_VAR_C1rest_avg = TstAcc_VAR_C1rest_avg + TstAcc_VAR_C1rest / k;
    TstAcc_MAVVAR_C1rest_avg = TstAcc_MAVVAR_C1rest_avg + TstAcc_MAVVAR_C1rest / k;
    TstAcc_MAV_C2rest_avg = TstAcc_MAV_C2rest_avg + TstAcc_MAV_C2rest / k;
    TstAcc_VAR_C2rest_avg = TstAcc_VAR_C2rest_avg + TstAcc_VAR_C2rest / k;
    TstAcc_MAVVAR_C2rest_avg = TstAcc_MAVVAR_C2rest_avg + TstAcc_MAVVAR_C2rest / k;
    TstAcc_MAV_C1C2_avg = TstAcc_MAV_C1C2_avg + TstAcc_MAV_C1C2 / k;
    TstAcc_VAR_C1C2_avg = TstAcc_VAR_C1C2_avg + TstAcc_VAR_C1C2 / k;
    TstAcc_MAVVAR_C1C2_avg = TstAcc_MAVVAR_C1C2_avg + TstAcc_MAVVAR_C1C2 / k;
end

%% Display the average performance metrics
disp('Average Test Accuracy for Class1 vs Rest');
disp(TstAcc_MAV_C1rest_avg);
disp(TstAcc_VAR_C1rest_avg);
disp(TstAcc_MAVVAR_C1rest_avg);
disp('Average Test Accuracy for Class2 vs Rest');
disp(TstAcc_MAV_C2rest_avg);
disp(TstAcc_VAR_C2rest_avg);
disp(TstAcc_MAVVAR_C2rest_avg);
disp('Average Test Accuracy for Class1 vs Class2');
disp(TstAcc_MAV_C1C2_avg);
disp(TstAcc_VAR_C1C2_avg);
disp(TstAcc_MAVVAR_C1C2_avg);

%%
figure()
subplot(3, 3, 1)
confusionchart(round(TstCM_MAV_C1rest))
title('MAV Confusion Matrix for Class1 vs Rest')
subplot(3, 3, 2)
confusionchart(round(TstCM_VAR_C1rest))
title('VAR Confusion Matrix for Class1 vs Rest')
subplot(3, 3, 3)
confusionchart(round(TstCM_MAVVAR_C1rest))
title('MAVVAR Confusion Matrix for Class1 vs Rest')
subplot(3, 3, 4)
confusionchart(round(TstCM_MAV_C2rest))
title('MAV Confusion Matrix for Class2 vs Rest')
subplot(3, 3, 5)
confusionchart(round(TstCM_VAR_C2rest))
title('VAR Confusion Matrix for Class2 vs Rest')
subplot(3, 3, 6)
confusionchart(round(TstCM_MAVVAR_C2rest))
title('MAVVAR Confusion Matrix for Class2 vs Rest')
subplot(3, 3, 7)
confusionchart(round(TstCM_MAV_C1C2))
title('MAV Confusion Matrix for Class1 vs Class2')
subplot(3, 3, 8)
confusionchart(round(TstCM_VAR_C1C2))
title('VAR Confusion Matrix for Class1 vs Class2')
subplot(3, 3, 9)
confusionchart(round(TstCM_MAVVAR_C1C2))
title('MAVVAR Confusion Matrix for Class1 vs Class2')
