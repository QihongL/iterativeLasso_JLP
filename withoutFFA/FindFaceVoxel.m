%% For a given subject, find voxels belongs to the face system!
% @param - subNum: the subject ID
% @return - a logical vector that indicates if a voxel belongs to FFA

function [faceVoxelIndex] = FindFaceVoxel(subNum)



% load the metadata 
% NEW MASKS
METADATA_PATH = '/Users/lcnl/Documents/MATLAB/JLP/data/selectedFunctionalData';
filename = sprintf('jlp%.2d_hc_X_conds.mat',subNum);
load('handConsMasks.mat')
xyz1 = cortices{subNum}.xyz;

% OLD MASKS
% METADATA_PATH = '/Users/lcnl/Documents/MATLAB/JLP/data';
% filename = sprintf('jlp_metadata.mat');
% load(fullfile(METADATA_PATH,filename));
% xyz1 = metadata(subNum).xyz_tlrc;

% load the the coordinates for all face voxels 

load('FaceCoordinates.mat')

%% Round to 3x3x3

% find IJK for face system 
faceIJK = bsxfun(@minus,FaceCoordinates, min([xyz1;FaceCoordinates]));
faceIJK = unique(round( faceIJK / 3),'rows') + 1;
faceIJKSplat = mat2cell(faceIJK, size(faceIJK,1), ones(1,size(faceIJK,2)));

% find ijk for subject
ijk = bsxfun(@minus,xyz1, min([xyz1;FaceCoordinates]));
ijk = round( ijk / 3) + 1;
ijkSplat = mat2cell(ijk, size(ijk,1), ones(1,size(ijk,2)));

% find common dimension
commonDims = max([ijk; faceIJK]);

% construct column indices
ind = sub2ind(commonDims,ijkSplat{:});
indFace = sub2ind(commonDims,faceIJKSplat{:});

% find intersection 
faceVoxelIndex = ismember(ind, indFace);
numFaceVoxels = sum(ismember(ind, indFace));
fprintf('Subject %d \t number of voxels %d \n', ...
    subNum, numFaceVoxels);



%% Alternative method 

% face333 = unique(round(FaceCoordinates ./ 3) * 3, 'rows');
% face333Splat = mat2cell(face333, size(face333,1), ones(1,size(face333,2)));
% xyz333 = round(xyz1 / 3) * 3;
% xyz333Splat = mat2cell(xyz333, size(xyz333,1), ones(1,size(xyz333,2)));
% 
% 
% sum(ismember(xyz333, face333,'rows'))

end