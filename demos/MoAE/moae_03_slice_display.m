% This script shows how to display the results of a GLM
% by having on the same image:
%
% - the beta estimates
% - the t statistics
% - ROI contours
%
%

% (C) Copyright 2021 Remi Gau

clear;
close all;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

this_dir = fileparts(mfilename('fullpath'));

subLabel = '01';

opt.pipeline.type = 'stats';

opt.dir.raw = fullfile(this_dir, 'inputs', 'raw');
opt.dir.derivatives = fullfile(this_dir, 'outputs', 'derivatives');
opt.dir.preproc = fullfile(opt.dir.derivatives, 'bidspm-preproc');

opt.dir.roi = fullfile(opt.dir.derivatives, 'bidspm-roi');
opt.dir.stats = fullfile(opt.dir.derivatives, 'bidspm-stats');

opt.model.file = fullfile(this_dir, 'models', 'model-MoAE_smdl.json');

opt.subjects = [subLabel];

% read the model
opt = checkOptions(opt);

iRes = 1;

opt.results = opt.model.bm.Nodes{iRes}.Model.Software.bidspm.Results{1};

node = opt.model.bm.Nodes{iRes};
[opt, BIDS] = checkMontage(opt, iRes, node, struct([]), subLabel);

opt = checkOptions(opt);

opt.results(iRes).montage = setMontage(opt.results(iRes));

% we get the con image to extract data
ffxDir = getFFXdir(subLabel, opt);

maskImage = spm_select('FPList', ffxDir, '^.*_mask.nii$');
bf = bids.File(spm_file(maskImage, 'filename'));
conImage = spm_select('FPList', ffxDir, ['^con_' bf.entities.label '.nii$']);

%% Layers to put on the figure
layers = sd_config_layers('init', {'truecolor', 'dual', 'contour'});

% Layer 1: Anatomical map
layers(1).color.file = opt.results(iRes).montage.background{1};

hdr = spm_vol(layers(1).color.file);
[max_val, min_val] = slover('volmaxmin', hdr);
layers(1).color.range = [0 max_val];

layers(1).color.map = gray(256);

%% Layer 2: Dual-coded layer
%
%   - contrast estimates color-coded;

layers(2).color.file = conImage;

color_map_folder = fullfile(fileparts(which('map_luminance')), '..', 'mat_maps');
load(fullfile(color_map_folder, 'diverging_bwr_iso.mat'));
layers(2).color.map = diverging_bwr;

layers(2).color.range = [-4 4];
layers(2).color.label = '\beta_{listening} - \beta_{baseline} (a.u.)';

%% Layer 2: Dual-coded layer
%
%   - t-statistics opacity-coded

spmTImage = spm_select('FPList', ffxDir, ['^spmT_' bf.entities.label '.nii$']);
layers(2).opacity.file = spmTImage;

layers(2).opacity.range = [0 3];
layers(2).opacity.label = '| t |';

%% Layer 3 and 4: Contour of ROI
contour = spm_select('FPList', ffxDir, ['^sub.*' bf.entities.label '.*_mask.nii']);
layers(3).color.file = contour;
layers(3).color.map = [0 0 0];
layers(3).color.line_width = 2;

%% Settings
settings = sd_config_settings('init');

% we reuse the details for the SPM montage
settings.slice.disp_slices = opt.results(1).montage.slices;
settings.slice.orientation = opt.results(1).montage.orientation;
settings.fig_specs.n.slice_column = 4;
settings.fig_specs.title = opt.results(1).name;

%% Display the layers
[settings, p] = sd_display(layers, settings);
