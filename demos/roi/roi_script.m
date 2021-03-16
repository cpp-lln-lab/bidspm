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
opt.save.roi = true;

[roiName, probabilityMap] = preprareDataAndROI(opt, dataImage, probabilityMap)
expected_mask = getDataFromMask(opt, dataImage,  roiName);
expected_sphere = getDataFromSphere(opt, dataImage);
expected_intersection = getDataFromIntersection(opt, dataImage,  roiName);
expected_expand = getDataFromExpansion(opt, dataImage,  roiName);

%% Mini functions

% only to show how each case works

function expected_mask = getDataFromMask(opt, dataImage,  roiName)
    
    expected_mask = spm_summarise(dataImage, roiName);
    
    if opt.reslice.do
        % to test home made code
        mask = createROI('mask', roiName, opt.save.roi);
        data = getRoiData(dataImage, mask);
        assertEqual(data, expected_mask);
    end
    
end

function expected_sphere = getDataFromSphere(opt, dataImage)
    
    % X Y Z coordinates of right V5 in millimeters
    location = [44 -67 0];
    
    % radius in millimeters
    radius = 3;
    
    mask.location = location;
    mask.radius = radius;
    mask = createROI('sphere', mask, dataImage, opt.save.roi);
    
    expected_sphere = spm_summarise(dataImage, mask);
    
    % equivalent to
    % b = spm_summarise('beta_0001.nii', ...
    %                   struct( ...
    %                          'def', 'sphere', ...
    %                          'spec', 1, ...
    %                          'xyz', [-7.46 -31.01 7.78]'));
    
end

function expected_intersection = getDataFromIntersection(opt, dataImage,  roiName)
    
    % X Y Z coordinates of right V5 in millimeters
    location = [44 -67 0];
    
    sphere.location = location;
    sphere.radius = 3;
    mask = createROI('intersection', roiName, sphere, opt.save.roi);
    
    expected_intersection = spm_summarise(dataImage, mask.roi.XYZmm);
    
end

function expected_expand = getDataFromExpansion(opt, dataImage,  roiName)
    
    % X Y Z coordinates of right V5 in millimeters
    location = [44 -67 0];
    
    sphere.location = location;
    sphere.radius = 1; % starting radius
    sphere.maxNbVoxels = 500;
    mask = createROI('expand', roiName, sphere, opt.save.roi);
    
    data = getRoiData(dataImage, mask);
    
    expected_expand = spm_summarise(dataImage, mask.roi.XYZmm);
    
    assertEqual(data, expected_expand)
end


%% HELPER FUNCTION

function [roiName, probabilityMap] = preprareDataAndROI(opt, dataImage, probabilityMap)
    
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
    
end