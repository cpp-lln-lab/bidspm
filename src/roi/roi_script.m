%% example to create ROI and extract data

% ROI: use the probability map for visual motion from Neurosynth
%   link: https://neurosynth.org/analyses/terms/visual%20motion/
%
% Data: tmap of visual-looming stim from Neurovault
%   collection : https://neurovault.org/collections/5209/
%   file: https://neurovault.org/media/images/5209/spm_0001_1.nidm/TStatistic.nii.gz

clear
clc

%% ASSUMPTION

% this assumes that the 2 immages are in the same space (MNI, individual)
% but they might not necessarily have the same resolution.
%
% In SPM lingo this means they are coregistered but not necessarily resliced.
%
% If they have different resolution we 
%

%% Preprare data and ROI

% TODO: don't store the data locally
% URL = 'https://neurovault.org/media/images/5209/spm_0001_1.nidm/TStatistic.nii.gz';
% urlwrite(URL, fullfile(pwd, 'TStatistic.nii'));

% gunzip('*.gz')

probabiliyMap = fullfile(pwd, 'visual motion_association-test_z_FDR_0.01.nii');
dataImage = fullfile(pwd, 'TStatistic.nii');

% If needed reslice probability map to have same resolution as the data image
% resliceImg won't do anything if the 2 images have the same resolution
reslicedProbabilityMap = resliceImages(dataImage, probabiliyMap);

% Threshold probability map into a binary mask 
% to keep only values above a certain threshold
threshold = 10;
roiName = thresholdToMask(reslicedProbabilityMap, threshold);

%% Get ROI voxel coordinates and extract data
mask = createROI(roiName);
data = getRoiData(dataImage, mask);

%% Get data from a sphere at a specific location


