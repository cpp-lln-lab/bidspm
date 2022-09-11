% This script shows how to create a ROI and extract data from it.
%
% .. warning::
%
%   This is "double dipping" as we use the same data to create the ROI
%   we are going to extract the value from.
%
% (C) Copyright 2021 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

subLabel = '01';

opt.dir.derivatives = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'derivatives');
opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');
opt.dir.stats = fullfile(opt.dir.derivatives, 'outputs', 'cpp_spm-stats');

opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                          'models', 'model-MoAE_smdl.json');
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

bf = bids.File(roiFile);

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

rightRoiFile = bf.rename('spec', newname, 'dry_run', false, 'verbose', true);

%% same but with left hemisphere
sphere.location = [-57 -22 11];

specification  = struct('mask1', maskImage, ...
                        'mask2', sphere);

[~, roiFile] = createRoi('expand', specification, conImage, output_dir, saveROI);

bf = bids.File(roiFile);

newname.entities.hemi = 'L';

leftRoiFile = bf.rename('spec', newname, 'dry_run', false, 'verbose', true);

%%
right_data = spm_summarise(conImage, fullfile(output_dir, rightRoiFile.filename));
left_data = spm_summarise(conImage, fullfile(output_dir, leftRoiFile.filename));
