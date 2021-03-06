%% overlap analysis
clear

for l = 1:3
    if l == 1
        label = 'TrueFaces';
        disp('TrueFaces: ')
    elseif l == 2
        label = 'TruePlaces';
        disp('TruePlaces: ')
    elseif l == 3
        label = 'TrueThings';
        disp('TrueThings: ')
    end


    heatVec = cell(1,9);
    xyz_adj = cell(1,9);
    for i = 1:9
        [heatVec{i}, xyz_adj{i}] = overlapMap(i, label);
    end

    %% analysis

    for i = 1:9
        totalVoxel(i) = sum(heatVec{i});
        uniqueVoxel(i) = (size(heatVec{i},1));
        maxoverlap(i) = (max(heatVec{i}));
    end

    % results
    fprintf('Statistics for overlapping voxels across subjects: \n')
    fprintf('Lower Boundary (exclusive):  ')
    fprintf('%6d', 1:9)
    fprintf('\nNumber of voxels (total):    ')
    fprintf('%6d', totalVoxel)
    fprintf('\nNumber of voxels (unique):   ')
    fprintf('%6d', uniqueVoxel)
    fprintf('\nNumber of overlapping Voxels:')
    fprintf('%6d', totalVoxel - uniqueVoxel)
    fprintf('\nMax overlap across subject:  ')
    fprintf('%6d', maxoverlap)
    fprintf('\n------------------------------\n')

end