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

probabilityMap = fullfile(pwd, 'visual motion_association-test_z_FDR_0.01.nii');
dataImage = fullfile(pwd, 'TStatistic.nii');

% If needed reslice probability map to have same resolution as the data image
%
% resliceImg won't do anything if the 2 images have the same resolution
%
% if you reed the data with spm_summarise, then the 2 images do not need the
% same resolution.

% reslicedProbabilityMap = resliceImages(dataImage, probabilityMap);

% Threshold probability map into a binary mask 
% to keep only values above a certain threshold
threshold = 10;

roiName = thresholdToMask(probabilityMap, threshold);
% roiNameHighRes = thresholdToMask(reslicedProbabilityMap, threshold);


%% Get ROI voxel coordinates and extract data
expected = spm_summarise(dataImage, roiName);

% mask = createROI('mask', roiNameHighRes);
% data = getRoiData(dataImage, mask);
% assertEqual(data, expected)
  
return

%% Get data from a sphere at a specific location
% X Y Z coordinates in millimeters
% location = [21.33 -94.83 1.40];  
location = [-7.46 -31.01 7.78]; 

% radius in millimeters
radius = 1;

sphere.location = location;
sphere.radius = radius;

imageToSample = dataImage;
sphere = createROI('sphere', sphere);
% data = getRoiData(dataImage, mask);
expected = spm_summarise(dataImage, sphere);




b = spm_summarise('beta_0001.nii',...
      struct('def','sphere', 'spec',5, 'xyz',[10 20 30]'));