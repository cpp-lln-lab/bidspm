% This script shows how to display the results of a GLM
% by having on the same image:
%
%   - the beta estimates
%   - the t statistics
%   - ROI contours
%
% (C) Copyright 2021 Remi Gau

clear;
clc;

try
  run ../../initCppSpm.m;
catch
end

subLabel = '01';

opt = moae_get_option_stats();

use_schema = false;
BIDS_ROI = bids.layout(opt.dir.roi, use_schema);
rightRoiFile = bids.query(BIDS_ROI, 'data', 'sub', subLabel, 'desc', 'rightAuditoryCortex');
leftRoiFile = bids.query(BIDS_ROI, 'data', 'sub', subLabel, 'desc', 'leftAuditoryCortex');

% we get the con image to extract data
ffxDir = getFFXdir(subLabel, opt);
maskImage = spm_select('FPList', ffxDir, '^.*_mask.nii$');
p = bids.internal.parse_filename(spm_file(maskImage, 'filename'));
conImage = spm_select('FPList', ffxDir, ['^con_' p.entities.label '.nii$']);

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

spmTImage = spm_select('FPList', ffxDir, ['^spmT_' p.entities.label '.nii$']);
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
settings.slice.orientation = opt.result.Nodes(1).Output.montage.orientation;
settings.slice.disp_slices = opt.result.Nodes(1).Output.montage.slices;
settings.fig_specs.n.slice_column = 3;
settings.fig_specs.title = opt.result.Nodes(1).Contrasts(1).Name;

%% Display the layers
[settings, p] = sd_display(layers, settings);
