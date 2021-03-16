%% example to create ROI and extract data

% ROI: use the probability map for visual motion from Neurosynth
%   link: https://neurosynth.org/analyses/terms/visual%20motion/
%
% Data: tmap of visual-looming stim from Neurovault
%   collection : https://neurovault.org/collections/5209/
%   file: https://neurovault.org/media/images/5209/spm_0001_1.nidm/TStatistic.nii.gz

clear;
clc;

%% ASSUMPTION

% This assumes that the 2 immages are in the same space (MNI, individual)
% but they might not necessarily have the same resolution.
%
% In SPM lingo this means they are coregistered but not necessarily resliced.
%

probabilityMap = fullfile(pwd, 'inputs', 'visual motion_association-test_z_FDR_0.01.nii');
dataImage = fullfile(pwd, 'inputs', 'TStatistic.nii');

opt.reslice.do = true;
opt.download.do = false;
opt.unzip.do = false;

%% Preprare data and ROI

if opt.download.do
  % TODO: don't store the data locally
  % URL = 'https://neurovault.org/media/images/5209/spm_0001_1.nidm/TStatistic.nii.gz';
  % urlwrite(URL, fullfile(pwd, 'TStatistic.nii'));
end

if opt.unzip.do
  gunzip(fullfile('inputs', '*.gz'));
end

if opt.reslice.do
  % If needed reslice probability map to have same resolution as the data image
  %
  % resliceImg won't do anything if the 2 images have the same resolution
  %
  % if you read the data with spm_summarise, then the 2 images do not need the
  % same resolution.
  probabilityMap = resliceImages(dataImage, probabilityMap);
end

% Threshold probability map into a binary mask
% to keep only values above a certain threshold
threshold = 10;
roiName = thresholdToMask(probabilityMap, threshold);

%% Get ROI voxel coordinates and extract data
expected = spm_summarise(dataImage, roiName);

if opt.reslice.do
  % only to test home made code
  mask = createROI('mask', roiName);
  data = getRoiData(dataImage, mask);
  assertEqual(data, expected);
end

%% Get data from a sphere at a specific location
% X Y Z coordinates of right V5 in millimeters
location = [44 -67 0];

% radius in millimeters
radius = 5;

mask.location = location;
mask.radius = radius;
mask = createROI('sphere', mask);

expected_sphere = spm_summarise(dataImage, mask);

% equivalent to
% b = spm_summarise('beta_0001.nii', ...
%                   struct( ...
%                          'def', 'sphere', ...
%                          'spec', 1, ...
%                          'xyz', [-7.46 -31.01 7.78]'));

%% Get data from intersection of a ROI and a sphere
clear sphere;
% X Y Z coordinates of right V5 in millimeters
location = [44 -67 0];

sphere.location = location;
sphere.radius = 3;
mask = createROI('intersection', roiName, sphere);

expected_intersection = spm_summarise(dataImage, mask.roi.XYZmm);

%% Get data from a ROI grown within a mask till a certain size
clear sphere;
% X Y Z coordinates of right V5 in millimeters
location = [44 -67 0];

sphere.location = location;
sphere.radius = 1; % starting radius
sphere.maxNbVoxels = 1090;
mask = createROI('expand', roiName, sphere);

data = getRoiData(dataImage, mask);

expected_growth = spm_summarise(dataImage, mask.roi.XYZmm);
