%% Create ROI and extract data from it
%
% FYI: this is "double  dipping" as we use the same data to create the ROI
% we are going to extract the value from.
%

run MoAEpilot_run.m;

subLabel = '01';

saveROI = true;

sphere.location = [57 -22 11];
sphere.radius = 3;
sphere.maxNbVoxels = 200;

opt = setDerivativesDir(opt);
ffxDir = getFFXdir(subLabel, FWHM, opt);

maskImage = spm_select('FPList', ffxDir, '^.*_mask.nii$');

% we get the con image to extract data
% we can do this by using the "label-XXXX" from the mask
p = bids.internal.parse_filename(spm_file(maskImage, 'filename'));

conImage = spm_select('FPList', ffxDir, ['^con_' p.label '.nii$']);

specification  = struct( ...
    'mask1', maskImage, ...
    'mask2', sphere);

[~, roiFile] = createRoi('expand', specification, conImage, pwd, saveROI);

% rename mask image
newname.desc = 'left auditory cortex';
newname.task = '';
newname.label = '';
newname.p = '';
newname.k = '';
newname.MC = '';
roiFile = renameFile(roiFile, newname);

data = spm_summarise(conImage, roiFile);

