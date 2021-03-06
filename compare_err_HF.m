%% Analysis: compare two version of iterative lasso
% In this document, we are comparing the results of iterative lasso using
% two different methods: error or hit/ false alarm rate. These methods have
% direct influence on tuning lambda value and controling stopping
% criterion, which leads to quite different outcomes.
clear;clc;close all;


%% Pick a label
label = 'TrueThings';
% disp('------------------------------------------------')
disp(['Label = ' label]);



%% Number of solvable subject 
% Here, '1' means solvable whereas '0' means the subject was unsolvable
% such that the first two iterations were both insignificant. Base on the
% results, hit / false rate criterion is able to make more subjects
% solvable.

% Error
load(['JLP_ERR_' label '.mat']);
ERR.solvable = false(1,10);
for SubNum = 1:10
    i = SubNum;
    % final accuracy is NaN => not solvable
    if ~isnan(result(i).finalAccuracy(1))
        % Get the indices for non-solvable subject
        ERR.solvable(i) = true;
    end
    % Calculate the number of non-solvable subject
    ERR.solvable_num = sum(ERR.solvable);
end

% Error Mannual
load(['JLP_ERRmanual_' label '.mat']);
ERRmanual.solvable = false(1,10);
for SubNum = 1:10
    i = SubNum;
    % final accuracy is NaN => not solvable
    if ~isnan(result(i).finalAccuracy(1))
        % Get the indices for non-solvable subject
        ERRmanual.solvable(i) = true;
    end
    % Calculate the number of non-solvable subject
    ERRmanual.solvable_num = sum(ERRmanual.solvable);
end

% Hit/False
load(['JLP_HF_' label '.mat'])
HF.solvable = false(1,10);
for SubNum = 1:10
    i = SubNum;
    % final accuracy is NaN => not solvable
    if ~isnan(result(i).finalAccuracy(1))
        % Get the indices for non-solvable subject
        HF.solvable(i) = true;
    end
    % Calculate the number of non-solvable subject
    HF.solvable_num = sum(HF.solvable);
end


% Display number of solvable subjects
% disp('------------------------------------------------')
disp('Solvable subjects: ' );
disp(['Error:       ' num2str(ERR.solvable) '  =  ' num2str(ERR.solvable_num)])

% disp(['ErrorManual: ' num2str(ERRmanual.solvable) '  =  ' num2str(ERRmanual.solvable_num)])

disp(['Hit/False:   ' num2str(HF.solvable) '  =  ' num2str(HF.solvable_num)])



%% Feature selection
% Here's a comparison about the total number of voxels selected in the end.
% It seems that by using hit/false criterion, many more voxels were
% selected. This is also true when excluding unsolvable subjects. 


% Error
load(['JLP_ERR_' label '.mat']);
% Resource preallocation
ERR.voxels_all = zeros(10,10);
% Get data (This version does not exclude unsolvable subjects)
for SubNum = 1:10
    i = SubNum;
    ERR.voxels_all(i,:) = result(i).hitAll(end,:);
end

% Error Manual
load(['JLP_ERRmanual_' label '.mat']);
% Resource preallocation
ERRmanual.voxels_all = zeros(10,10);
% Get data (This version does not exclude unsolvable subjects)
for SubNum = 1:10
    i = SubNum;
    ERRmanual.voxels_all(i,:) = result(i).hitAll(end,:);
end

% For hit/false
load(['JLP_HF_' label '.mat'])
% Resource preallocation
HF.voxels_all = zeros(10,10);
% Get data (This version does not exclude unsolvable subjects)
for SubNum = 1:10
    i = SubNum;
    HF.voxels_all(i,:) = result(i).hitAll(end,:);
end

% t test
[t_all, p_all] = ttest(HF.voxels_all(:),ERR.voxels_all(:));
 
% exclude non-solvable subjects
ERR.voxels_solvableSub = ERR.voxels_all(ERR.solvable,:);
ERRmanual.voxels_solvableSub = ERRmanual.voxels_all(ERRmanual.solvable,:);
HF.voxels_solvableSub = HF.voxels_all(HF.solvable,:);
[t_solvable, p_solvable] = ttest( mean(HF.voxels_solvableSub),mean(ERR.voxels_solvableSub) );

% Display the total number of voxels were being selected (average accross subject)
% disp(' ')
% disp('------------------------------------------------')
disp('Total number of voxels were being selected : ' );

% fprintf('\t\t Error\t\t Hit/False \t T-test \t P-value \n' );
% fprintf('All_Sub %15.2f %16.2f %12d %17.4f \n', mean(ERR.voxels_all(:)), mean(HF.voxels_all(:)), t_all, p_all );
% fprintf('Solvable %14.2f %16.2f %12d %17.4f \n', mean(ERR.voxels_solvableSub(:)), mean(HF.voxels_solvableSub(:)), t_solvable, p_solvable );
% disp(' ');

%For comparing ERRcvglmnet vc cvglmnet

fprintf('\t\t All Sub \t Solvable Sub\n')

fprintf('Error:\t\t ')
fprintf('%7.2f  %13.2f \n', mean(ERR.voxels_all(:)), mean(ERR.voxels_solvableSub(:)))

% fprintf('ErrorManual:\t ')
% fprintf('%7.2f  %13.2f \n', mean(ERRmanual.voxels_all(:)), mean(ERRmanual.voxels_solvableSub(:)))

fprintf('Hit/False:\t ')
fprintf('%7.2f  %13.2f \n', mean(HF.voxels_all(:)), mean(HF.voxels_solvableSub(:)))


%% Tuning lambda values
% Here's a comparison for the lambda values used for lasso. More
% specifically, in each iteration of lasso, it needs to tune lambda, and
% here's the comparison for that lambda values across two criterion.
% Overall, hit / false rate criterion is giving us a smaller lambda value.

% disp('------------------------------------------------')
for numIter = 1:2
% numIter = 1;

    % Error
    load(['JLP_ERR_' label '.mat']);
    ERR.bestLambda = NaN(10,10);
    for subNum = 1:10
        i = subNum;
        ERR.bestLambda(i,:) = result(subNum).lassoBestLambda(numIter,:);
    end

    % For hit/false
    load(['JLP_HF_' label '.mat']);
    HF.bestLambda = NaN(10,10);
    for subNum = 1:10
        i = subNum;

        temp = zeros(1,10);
        for j = 1:10
            temp(j) = result(subNum).HF_tunning_lambda{numIter}(j).bestLambda;
        end

        HF.bestLambda(i,:) = temp;
    end

    t_lambda = ttest(ERR.bestLambda(:), HF.bestLambda(:));


    
    fprintf('Lambda value for iteration %d: \n', numIter)
    fprintf('\t\t Error\t\tHit/False \t  \n')
    fprintf('Lambda Value: %9.4f %14.4f  \n', mean(ERR.bestLambda(:)), mean(HF.bestLambda(:)))
    fprintf('T test: %10d \n', t_lambda)
end



%% Compare number of iterations 
% When considering all subjects, hit / false rate version runs more
% iterations on average. However, this effect seems subtle when excluding
% unsolvable subjects.

% Error
load(['JLP_ERR_' label '.mat']);
ERR.numIterAll = zeros(1,10);
for SubNum = 1:10
    i = SubNum;
    ERR.numIterAll(i) = size(result(i).lasso_sig,1);
end

% Error Mannual
load(['JLP_ERRmanual_' label '.mat']);
ERRmanual.numIterAll = zeros(1,10);
for SubNum = 1:10
    i = SubNum;
    ERRmanual.numIterAll(i) = size(result(i).lasso_sig,1);
end

% For hit/false
load(['JLP_HF_' label '.mat']);
HF.numIterAll = zeros(1,10);
for SubNum = 1:10
    i = SubNum;
    HF.numIterAll(i) = size(result(i).HFsig,1);
end



% Display reuslts
disp(' ')
% disp('------------------------------------------------')
disp('Number of iterations(all subjects): ' );
fprintf('Error\t\t')
fprintf('%4d  ', ERR.numIterAll)
fprintf(' = %.2f', mean(ERR.numIterAll))
fprintf('\n')

% % For comparing ERRcvglmnet vc cvglmnet
% fprintf('ErrorManual\t')
% fprintf('%4d  ', ERRmanual.numIterAll)
% fprintf(' = %.2f', mean(ERRmanual.numIterAll))
% fprintf('\n')

fprintf('Hit/False\t')
fprintf('%4d  ', HF.numIterAll)
fprintf(' = %.2f', mean(HF.numIterAll))
fprintf('\n')
disp(' ')

% Change unsolvable subjects to NaN
ERR.numIter_solvableSub = ERR.numIterAll .* ERR.solvable;
ERRmanual.numIter_solvableSub = ERRmanual.numIterAll .* ERRmanual.solvable;
HF.numIter_solvableSub = HF.numIterAll .* HF.solvable;

ERR.numIter_solvableSub(ERR.numIter_solvableSub == 0) = NaN;
ERRmanual.numIter_solvableSub(ERRmanual.numIter_solvableSub == 0) = NaN;
HF.numIter_solvableSub(HF.numIter_solvableSub == 0) = NaN;

disp('Number of iterations(excluding unsovlable subjects): ' );
fprintf('Error\t\t')
fprintf('%4d  ', ERR.numIter_solvableSub)
fprintf(' = %.2f', mean(ERR.numIterAll(ERR.solvable)))
fprintf('\n')

% fprintf('ErrorManual\t')
% fprintf('%4d  ', ERRmanual.numIter_solvableSub)
% fprintf(' = %.2f', mean(ERRmanual.numIterAll(ERR.solvable)))
% fprintf('\n')

fprintf('Hit/False \t')
fprintf('%4d  ', HF.numIter_solvableSub)
fprintf(' = %.2f', mean(HF.numIterAll(HF.solvable)))
fprintf('\n')
disp(' ')



%% Compare accuracy
% Unsurprisingly, iterative lasso using error obtained better accuracy. 

% Error
load(['JLP_ERR_' label '.mat']);
ERR.accuracy = zeros(1,10);
for SubNum = 1:10
    i = SubNum;
    ERR.accuracy(i) = mean(result(i).finalAccuracy);
end

% Error Manual
load(['JLP_ERRmanual_' label '.mat']);
ERRmanual.accuracy = zeros(1,10);
for SubNum = 1:10
    i = SubNum;
    ERRmanual.accuracy(i) = mean(result(i).finalAccuracy);
end

% For hit/false
load(['JLP_HF_' label '.mat']);
HF.accuracy = zeros(1,10);
for SubNum = 1:10
    i = SubNum;
    HF.accuracy(i) = mean(result(i).finalAccuracy);
end


% disp('------------------------------------------------')
disp('Final classification accuracy: ')
fprintf('Error:\t    ')
fprintf('%10.4f', ERR.accuracy);
fprintf('  = % 6.4f \n', nanmean(ERR.accuracy));

% fprintf('ErrorManual:')
% fprintf('%10.4f', ERRmanual.accuracy);
% fprintf('  = % 6.4f \n', nanmean(ERRmanual.accuracy));

fprintf('Hit/False:  ')
fprintf('%10.4f', HF.accuracy);
fprintf('  = % 6.4f \n', nanmean(HF.accuracy));
disp(' ')


%% Compare hit/false rate
% Suprisingly, iterative lasso using hit / false rate does not give a
% better hit / false rate. 


% Error
load(['JLP_ERR_' label '.mat']);
ERR.hitRate= zeros(1,10);
ERR.falseRate = zeros(1,10);
ERR.difference = zeros(1,10);
for SubNum = 1:10
    i = SubNum;
    ERR.hitRate(i) = mean(result(i).final_hitRate);
    ERR.falseRate(i) = mean(result(i).final_falseRate);
    ERR.difference(i) = mean(result(i).final_difference);
end

% Error manual
load(['JLP_ERRmanual_' label '.mat']);
ERRmanual.hitRate= zeros(1,10);
ERRmanual.falseRate = zeros(1,10);
ERRmanual.difference = zeros(1,10);
for SubNum = 1:10
    i = SubNum;
    ERRmanual.hitRate(i) = mean(result(i).final_hitRate);
    ERRmanual.falseRate(i) = mean(result(i).final_falseRate);
    ERRmanual.difference(i) = mean(result(i).final_difference);
end


% For hit/false
load(['JLP_HF_' label '.mat']);
HF.hitRate= zeros(1,10);
HF.falseRate = zeros(1,10);
HF.difference = zeros(1,10);
for SubNum = 1:10
    i = SubNum;
    HF.hitRate(i) = mean(result(i).final_hitRate);
    HF.falseRate(i) = mean(result(i).final_falseRate);
    HF.difference(i) = mean(result(i).final_difference);
end





% disp('------------------------------------------------')
disp('Final hit rate, false alarm rate and their differences: ')
fprintf('Error:\n')
fprintf('Hit Rate:   ')
fprintf('%10.4f', ERR.hitRate);
fprintf('  = % 6.4f \n', nanmean(ERR.hitRate));
fprintf('False Rate: ')
fprintf('%10.4f', ERR.falseRate);
fprintf('  = % 6.4f \n', nanmean(ERR.falseRate));
fprintf('Difference: ')
fprintf('%10.4f', ERR.difference);
fprintf('  = % 6.4f \n', nanmean(ERR.difference));
fprintf('\n')

% fprintf('ErrorManual:\n')
% fprintf('Hit Rate:   ')
% fprintf('%10.4f', ERRmanual.hitRate);
% fprintf('  = % 6.4f \n', nanmean(ERRmanual.hitRate));
% fprintf('False Rate: ')
% fprintf('%10.4f', ERRmanual.falseRate);
% fprintf('  = % 6.4f \n', nanmean(ERRmanual.falseRate));
% fprintf('Difference: ')
% fprintf('%10.4f', ERRmanual.difference);
% fprintf('  = % 6.4f \n', nanmean(ERRmanual.difference));
% fprintf('\n')

fprintf('Hit/False:\n')
fprintf('Hit Rate:   ')
fprintf('%10.4f', HF.hitRate);
fprintf('  = % 6.4f \n', nanmean(HF.hitRate));
fprintf('False Rate: ')
fprintf('%10.4f', HF.falseRate);
fprintf('  = % 6.4f \n', nanmean(HF.falseRate));
fprintf('Difference: ')
fprintf('%10.4f', HF.difference);
fprintf('  = % 6.4f \n', nanmean(HF.difference));
disp(' ')



