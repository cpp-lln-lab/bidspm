% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

%% examples to create ROIs and extract data

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

%% IMPORTANT: for saving ROIs

% http://marsbar.sourceforge.net/

% If you want to save the ROI you are creating, you must make sure that the ROI
% image you are using DOES have the same resolution as the image you will
% sample.
%
% You can use the resliceImages for that.

%%
probabilityMap = fullfile(pwd, 'inputs', 'visual motion_association-test_z_FDR_0.01.nii');
dataImage = fullfile(pwd, 'inputs', 'TStatistic.nii');

opt.download.do = false;
opt.unzip.do = true;
opt.save.roi = true;
if opt.save.roi
  opt.reslice.do = true;
else
  opt.reslice.do = false;
end

[roiName, probabilityMap] = preprareDataAndROI(opt, dataImage, probabilityMap);
data_mask = getDataFromMask(dataImage,  roiName);
data_sphere = getDataFromSphere(opt, dataImage);
data_intersection = getDataFromIntersection(opt, dataImage,  roiName);
data_expand = getDataFromExpansion(opt, dataImage,  roiName);

%% Mini functions

% only to show how each case works

function data_mask = getDataFromMask(dataImage, roiName)

  data_mask = spm_summarise(dataImage, roiName);

end

function data_sphere = getDataFromSphere(opt, dataImage)

  % X Y Z coordinates of right V5 in millimeters
  location = [44 -67 0];

  % radius in millimeters
  radius = 5;

  sphere.location = location;
  sphere.radius = radius;

  mask = createRoi('sphere', sphere, dataImage, opt.save.roi);

  data_sphere = spm_summarise(dataImage, mask);

  % equivalent to
  % b = spm_summarise('beta_0001.nii', ...
  %                   struct( ...
  %                          'def', 'sphere', ...
  %                          'spec', 1, ...
  %                          'xyz', [-7.46 -31.01 7.78]'));

end

function data_intersection = getDataFromIntersection(opt, dataImage,  roiName)

  % X Y Z coordinates of right V5 in millimeters
  location = [44 -67 0];

  sphere.location = location;
  sphere.radius = 5;

  mask = createRoi('intersection', roiName, sphere, dataImage, opt.save.roi);

  data_intersection = spm_summarise(dataImage, mask.roi.XYZmm);

end

function data_expand = getDataFromExpansion(opt, dataImage,  roiName)

  % X Y Z coordinates of right V5 in millimeters
  location = [44 -67 0];

  sphere.location = location;
  sphere.radius = 1; % starting radius
  sphere.maxNbVoxels = 200;

  mask = createRoi('expand', roiName, sphere, dataImage, opt.save.roi);

  data_expand = spm_summarise(dataImage, mask.roi.XYZmm);

end

%% HELPER FUNCTION

function [roiName, probabilityMap] = preprareDataAndROI(opt, dataImage, probabilityMap)

  if opt.download.do
    % TODO: don't store the data locally
    % URL = 'https://neurovault.org/media/images/5209/spm_0001_1.nidm/TStatistic.nii.gz';
    % urlwrite(URL, fullfile(pwd, 'inputs', 'TStatistic.nii'));
  end

  if opt.unzip.do
    gunzip(fullfile('inputs', '*.gz'));
  end

  if opt.reslice.do
    % If needed reslice probability map to have same resolution as the data image
    %
    % resliceImg won't do anything if the 2 images have the same resolution
    %
    % if you read the data with spm_summarise,
    % then the 2 images do not need the same resolution.
    probabilityMap = resliceRoiImages(dataImage, probabilityMap);
  end

  % Threshold probability map into a binary mask
  % to keep only values above a certain threshold
  threshold = 10;
  roiName = thresholdToMask(probabilityMap, threshold);

end
