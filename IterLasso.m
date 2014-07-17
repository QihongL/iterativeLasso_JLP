function [ hit, final, lasso, ridge, used, USED ] = iterLasso( X, Y, CVBLOCKS, SubNum )
%% Iterative Lasso
% This function preform iterative Lasso
% It needs the following inputs: 
% % % X: The data set
% % % Y: The row labels
% % % CVBLOCKS: The cv indices
% % % SubNum: The subject number 


%% Prepare for iterative lasso
% The number of voxels
nvoxels = size(X,2);
% The number of CV blocks
k = 10;
% The size for the testing set 
test.size = size(X,1)/k;
% Keeping track of the number of iteration
numIter = 0;
% Keeping track of number of significant iteration
numSig = 0;
% Stopping criterion 
% Iterative Lasso stops when t-test insignificant twice
STOPPING_COUNTER = 0;
STOPPING_RULE = 2;  
chance = 2/3 + 1e-4;
% Create a matrix to index voxels that have been used (Chris' method)
used = false(k,nvoxels);

    
    
%% Start iterative Lasso 
    
while true
    numIter = numIter + 1;
    textprogressbar(['Iterative Lasso: ' num2str(numIter) ' -> ' ]);
    for CV = 1:k    
        textprogressbar(CV * 10);

        % Find the holdout set
        FINAL_HOLDOUT = CVBLOCKS(:,CV);
        % CV Indices for cvglmnet
        CV2 = CVBLOCKS(~FINAL_HOLDOUT,(1:k)~=CV); 
        fold_id = sum(bsxfun(@times,double(CV2),1:9),2);    

        % Subset the data, choose only used voxels
        Xiter = X(:,~used(CV,:));
        % Subset Training and testing data 
        Xtrain = Xiter(~FINAL_HOLDOUT,:);
        Xtest = Xiter(FINAL_HOLDOUT,:);
        Ytrain = Y(~FINAL_HOLDOUT);  
        Ytest = Y(FINAL_HOLDOUT);    

        % Use Lasso
        opts = glmnetSet();
        opts.alpha = 1;
        % Fit lasso with cv
        fitObj_cv = cvglmnet(Xtrain,Ytrain,'binomial', opts, 'class',9,fold_id');
        % Pick the best lambda
        opts.lambda = fitObj_cv.lambda_min;
        % Fit lasso
        fitObj = glmnet(Xtrain, Ytrain, 'binomial', opts);
        % Record the classification accuracy
        test.prediction(:,CV) = (Xtest * fitObj.beta + repmat(fitObj.a0, [test.size, 1])) > 0 ;
        lasso.accuracy(:,CV) = mean(Ytest == test.prediction(:,CV))';
        
        % Releveling 
        opts = glmnetSet();
        opts.alpha = 0;
        % Choose lambda
        fitObj_cv_ridge = cvglmnet(Xtrain,Ytrain,'binomial', opts, 'class',9,fold_id');
        opts.lambda = fitObj_cv_ridge.lambda_min;
        % Fitting ridge regression
        fitObj_ridge = glmnet(Xtrain, Ytrain, 'binomial', opts);
        % Record releveling accuracy
        r.prediction(:,CV) = (Xtest * fitObj_ridge.beta + repmat(fitObj_ridge.a0, [test.size, 1])) > 0 ;  
        ridge.accuracy(:,CV) = mean(Ytest == r.prediction(:,CV))';
        
        

        % Keeping track of which set of voxels were used in each cv block
%         if ttest(lasso.accuracy, chance, 'Tail', 'right') == 1
%             used( CV, ~used(CV,:) ) = fitObj.beta ~= 0;
%         end
                
        used( CV, ~used(CV,:) ) = fitObj.beta ~= 0;

    end
    textprogressbar('Done.\n') 
   

    % Take a snapshot, find out all voxels were used at this time point
    USED{numIter} = used;

    % Record the results, including 
    % 1) hit.accuracy: the accuracy for the correspoinding cv block        
    hit.accuracy(numIter, :) = lasso.accuracy;            
    % 2) hit.all : how many voxels have been selected        
    hit.all(numIter, :) = sum(used,2);
    % 3) hit.current: how many voxels have been selected in current
    % iteration
    if numIter == 1
        hit.current(1,:) = hit.all(1,:);
    else
        hit.current(numIter,:) = hit.all(numIter,: ) - hit.all(numIter - 1,:) ;
    end
    
 

    %% Printing some results
    % Keep track of the number of iteration.
%     disp(['Iteration number: ' num2str(numIter)]);
    
    % Display the average accuracy for this procedure 

    
    % Test classification accuracy aganist chance 
    [t,p] = ttest(lasso.accuracy, chance, 'Tail', 'right');

    if t == 1 % t could be NaN
        numSig = numSig + 1;
        disp(['Result for the t-test: ' num2str(t) ',  P = ' num2str(p), ' *']) 
    else
        disp(['Result for the t-test: ' num2str(t) ',  P = ' num2str(p)]) 
    end
    
    disp('The accuracy for each CV: ');
    disp(num2str(lasso.accuracy));
    disp(['The mean classification accuracy: ' num2str(mean(lasso.accuracy))]);
    disp(['Releveling accuracy using ridge: ' num2str(mean(ridge.accuracy))])   
    
    disp('Number of voxels that were selected by Lasso (cumulative):')
    disp(hit.all(numIter,:))   
    disp('Number of voxels that were selected by Lasso in the current iteration:')    
    disp(hit.current(numIter,:))


    %% Stop iteration, when the decoding accuracy is not better than chance
    if t ~= 1   %  ~t will rise a bug, when t is NaN
        STOPPING_COUNTER = STOPPING_COUNTER + 1;

        if STOPPING_COUNTER == STOPPING_RULE;
        % stop, if t-test = 0 n times, where n = STOPPING_RULE
            disp(' ')
            disp('* Iterative Lasso was terminated, as the classification accuracy is at chance level.')
            disp(' ')
            break
        end

    else
        STOPPING_COUNTER = 0;
    end 

end

%% Pooling solution and fitting ridge regression
textprogressbar('Fitting ridge on pooled solution: ' );
for CV = 1:k
    textprogressbar(CV * 10)
    % Subset: find voxels that were selected 
    Xfinal = X( :, USED{numIter - STOPPING_RULE}(CV,:) );

    % Split the final data set to testing set and training set 
    Xtest = Xfinal(CVBLOCKS(:,CV) ,:);
    Xtrain = Xfinal(~CVBLOCKS(:,CV) ,:);
 
    % Fit cvglmnet using ridge (find the best lambda)
    opts = glmnetSet(); 
    opts.alpha = 0;    
    fitObj_cvFinal = cvglmnet (Xtrain,Ytrain,'binomial', opts, 'class',9,fold_id');
    
    
    % Use the best lambda value
%     opts.lambda = fitObj_cvFinal.lambda_min;
    opts.lambda = fitObj_cvFinal.lambda_1se;

    % Fit glmnet 
    fitObj_Final = glmnet(Xtrain, Ytrain, 'binomial', opts);

    % Calculating accuracies
    final.prediction(:,CV) = (Xtest * fitObj_Final.beta + repmat(fitObj_Final.a0, [test.size, 1])) > 0 ;  
    final.accuracy(CV) = mean(Ytest == final.prediction(:,CV))';

end
textprogressbar('Done.\n')


disp('Final accuracies: ')
disp('(row: CV that just performed; colum: CV block from the iterative Lasso)')
disp(final.accuracy)
disp('Mean accuracy: ')
disp(mean(final.accuracy))
end
