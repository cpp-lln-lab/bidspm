% This script shows how to display the results of a GLM
% by having on the same image:
%
%   - the beta estimates
%   - the t statistics
%   - ROI contours
%
% (C) Copyright 2021 Remi Gau

clear;
close all;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

this_dir = fileparts(mfilename('fullpath'));

subLabel = '01';

opt.pipeline.type = 'stats';

opt.dir.raw = fullfile(this_dir, 'inputs', 'raw');
opt.dir.derivatives = fullfile(this_dir, 'outputs', 'derivatives');
opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');

opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');
opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');

opt.model.file = fullfile(this_dir, 'models', 'model-MoAE_smdl.json');

% Specify the result to compute
opt.results(1).nodeName = 'run_level';

opt.results(1).name = 'listening';
% MONTAGE FIGURE OPTIONS
opt.results(1).montage.do = true();
opt.results(1).montage.slices = -4:2:16; % in mm
% axial is default 'sagittal', 'coronal'
opt.results(1).montage.orientation = 'axial';
% will use the MNI T1 template by default but the underlay image can be changed.
opt.results(1).montage.background = ...
    fullfile(spm('dir'), 'canonical', 'avg152T1.nii');

opt = checkOptions(opt);

use_schema = false;
BIDS_ROI = bids.layout(opt.dir.roi, 'use_schema', use_schema);

filter = struct('sub', subLabel, ...
                'hemi', 'R', ...
                'desc', 'auditoryCortex');

rightRoiFile = bids.query(BIDS_ROI, 'data', filter);

filter.hemi = 'L';

leftRoiFile = bids.query(BIDS_ROI, 'data', filter);

% we get the con image to extract data
ffxDir = getFFXdir(subLabel, opt);
maskImage = spm_select('FPList', ffxDir, '^.*_mask.nii$');
bf = bids.File(spm_file(maskImage, 'filename'));
conImage = spm_select('FPList', ffxDir, ['^con_' bf.entities.label '.nii$']);

%% Layers to put on the figure
layers = sd_config_layers('init', {'truecolor', 'dual', 'contour', 'contour'});

% Layer 1: Anatomical map
[anat_normalized_file, anatRange] = return_normalized_anat_file(opt, subLabel);
layers(1).color.file = anat_normalized_file;
layers(1).color.range = [0 anatRange(2)];

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

layers(2).opacity.range = [2 3];
layers(2).opacity.label = '| t |';

%% Layer 3 and 4: Contour of ROI

layers(3).color.file = rightRoiFile{1};
layers(3).color.map = [0 0 0];
layers(3).color.line_width = 2;

layers(4).color.file = leftRoiFile{1};
layers(4).color.map = [1 1 1];
layers(4).color.line_width = 2;

%% Settings
settings = sd_config_settings('init');

% we reuse the details for the SPM montage
settings.slice.orientation = opt.results(1).montage.orientation;
settings.slice.disp_slices = -15:3:18;
settings.fig_specs.n.slice_column = 4;
settings.fig_specs.title = opt.results(1).name;

%% Display the layers
[settings, p] = sd_display(layers, settings);
