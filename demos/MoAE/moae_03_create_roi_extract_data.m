% This script shows how to create a ROI and extract data from it.
%
% FYI: this is "double  dipping" as we use the same data to create the ROI
% we are going to extract the value from.
%
% (C) Copyright 2021 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

subLabel = '01';

opt = moae_get_option_stats();
opt.pipeline.type = 'stats';
opt = checkOptions(opt);

%% Get the con image to extract data
% we can do this by using the "label-XXXX"
% from the mask created by the contrast estimation in the previous step
ffxDir = getFFXdir(subLabel, opt);
maskImage = spm_select('FPList', ffxDir, '^.*_mask.nii$');
bf = bids.File(spm_file(maskImage, 'filename'));
conImage = spm_select('FPList', ffxDir, ['^con_' bf.entities.label '.nii$']);

%% Create ROI right auditory cortex
saveROI = true;

sphere.radius = 3;
sphere.maxNbVoxels = 200;
sphere.location = [57 -22 11];
specification  = struct( ...
                        'mask1', maskImage, ...
                        'mask2', sphere);

output_dir = fullfile(opt.dir.roi, ['sub-' subLabel], 'roi');
spm_mkdir(output_dir);

[~, roiFile] = createRoi('expand', specification, conImage, output_dir, saveROI);

% rename mask image:
% add a description and remove a whole bunch of entities
% from the original name
newname.entities.hemi = 'R';
newname.entities.desc = 'auditory cortex';
newname.entities.task = '';
newname.entities.label = '';
newname.entities.p = '';
newname.entities.k = '';
newname.entities.MC = '';
newname.entity_order = {'sub', 'hemi', 'space', 'desc'};
rightRoiFile = renameFile(roiFile, newname);

%% same but with left hemisphere
sphere.location = [-57 -22 11];

specification  = struct( ...
                        'mask1', maskImage, ...
                        'mask2', sphere);

[~, roiFile] = createRoi('expand', specification, conImage, output_dir, saveROI);
newname.entities.hemi = 'L';
leftRoiFile = renameFile(roiFile, newname);

%%
right_data = spm_summarise(conImage, fullfile(output_dir, rightRoiFile));
left_data = spm_summarise(conImage, fullfile(output_dir, leftRoiFile));
