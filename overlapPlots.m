%% Outputs voxel overlap heatmap 
% Overlap across subjects
clear;

% Set some variables
label = 'TrueFaces';
lowerBound = 9;

% Get overlap heat map -> overlapping voxels across all subjects
[heatVec, coordinates] = overlapMap(lowerBound, label);
heatmap = [coordinates, heatVec];

% Write to txt
heatmap2txt('TESTING.txt', heatmap)