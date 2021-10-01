% (C) Copyright 2021 Remi Gau

%% Create ROI and extract data from it
%
% FYI: this is "double  dipping" as we use the same data to create the ROI
% we are going to extract the value from.
%

run moae_run.m;

subLabel = '01';

saveROI = true;

sphere.radius = 3;
sphere.maxNbVoxels = 200;

opt = setDerivativesDir(opt);
ffxDir = getFFXdir(subLabel, FWHM, opt);

maskImage = spm_select('FPList', ffxDir, '^.*_mask.nii$');

% we get the con image to extract data
% we can do this by using the "label-XXXX" from the mask
p = bids.internal.parse_filename(spm_file(maskImage, 'filename'));
conImage = spm_select('FPList', ffxDir, ['^con_' p.entities.label '.nii$']);

%% Create ROI right auditory cortex
sphere.location = [57 -22 11];

specification  = struct( ...
                        'mask1', maskImage, ...
                        'mask2', sphere);

[~, roiFile] = createRoi('expand', specification, conImage, pwd, saveROI);

% rename mask image
newname.entities.desc = 'right auditory cortex';
newname.entities.task = '';
newname.entities.label = '';
newname.entities.p = '';
newname.entities.k = '';
newname.entities.MC = '';
rightRoiFile = renameFile(roiFile, newname);

%% same but with left hemisphere
sphere.location = [-57 -22 11];

specification  = struct( ...
                        'mask1', maskImage, ...
                        'mask2', sphere);

[~, roiFile] = createRoi('expand', specification, conImage, pwd, saveROI);
newname.desc = 'left auditory cortex';
leftRoiFile = renameFile(roiFile, newname);

%%
right_data = spm_summarise(conImage, rightRoiFile);
left_data = spm_summarise(conImage, leftRoiFile);
