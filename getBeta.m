% This function get the BETAs using the output of iterativeLasso 
% @param: subNum - the subject id
% @param: cv - the cross validation block 
% @param: label - face, place or object (in the JLP context)
% @param: type - ERR or HF? (specific to our way of storing the iterLasso results)
function [beta, intercept] = getBeta( subNum, cv, label, type ) 

    % CONSTANTS
    STOPPING_RULE = 1;
    % load the data
    load(['fitStore_' type '.mat'])
    load(['JLP_' type '_' label '.mat'])

    % get the weights (BETA)
    intercept = fitStore.(label)(subNum).cv(cv).a0;
    finalBeta = fitStore.(label)(subNum).cv(cv).beta;
    % determine the iteration number 
    iterNum = size(result(subNum).used, 2) - STOPPING_RULE;

    % Indices for the voxels that were selected 
    voxel_used = result(subNum).used{iterNum}(cv,:);

    % initialize counter
    i = 1;
    % preallocate
    nvoxel = size(voxel_used,2);
    beta = zeros(1, nvoxel);

    % if no voxel was selected, beta = 0
    if size(fitStore.(label)(subNum).cv(cv).beta,1) == 0
        beta = 0;
        intercept = 0;
    else
    % loop over all voxels   
        for vox = 1 : size(voxel_used,2)
            if voxel_used(vox) == 1
                beta(vox) = finalBeta(i);
                i = i + 1;
            end
        end   
    end

    % transpose for convenience 
    beta = beta';

end