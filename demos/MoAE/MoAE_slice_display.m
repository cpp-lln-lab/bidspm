% (C) Copyright 2021 Remi Gau

run MoAE_run.m;
run MoAE_create_roi_extract_data.m;

close all;

%% Layers
layers = sd_config_layers('init', {'truecolor', 'dual', 'contour', 'contour'});

% Layer 1: Anatomical map
[anat_normalized_file, anatRange] = return_normalized_anat_file(opt, subLabel);
layers(1).color.file = anat_normalized_file;
layers(1).color.range = [0 anatRange(2)];

layers(1).color.map = gray(256);

% % Layer 2: Dual-coded layer
%
%   - contrast estimates color-coded;
%   - t-statistics opacity-coded

layers(2).color.file = conImage;

sd_dir = fileparts(which('sd_display'));
load(fullfile(sd_dir, 'colormaps.mat'));
layers(2).color.map = CyBuGyRdYl;

layers(2).color.range = [-6 6];
layers(2).color.label = '\beta_{listening} - \beta_{baseline} (a.u.)';

spmTImage = spm_select('FPList', ffxDir, ['^spmT_' p.label '.nii$']);
layers(2).opacity.file = spmTImage;

layers(2).opacity.label = '| t |';
layers(2).opacity.range = [0 5];

% % Layer 3 and 4: Contour of ROI

layers(3).color.file = rightRoiFile;
layers(3).color.map = [0 0 0];
layers(3).color.line_width = 2;

layers(4).color.file = leftRoiFile;
layers(4).color.map = [1 1 1];
layers(4).color.line_width = 2;

%% Settings
settings = sd_config_settings('init');

% we reuse the details for the SPM montage
settings.slice.orientation = opt.result.Steps(1).Output.montage.orientation;
settings.slice.disp_slices = opt.result.Steps(1).Output.montage.slices;
settings.fig_specs.n.slice_column = 3;
settings.fig_specs.title = opt.result.Steps(1).Contrasts(1).Name;

%% Display the layers
[settings, p] = sd_display(layers, settings);

%% Helper function
function [anat_normalized_file, anatRange] = return_normalized_anat_file(opt, subLabel)

  [BIDS, opt] = getData(opt);
  [~, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);
  anat_normalized_file = spm_select('FPList', ...
                                    anatDataDir, ...
                                    '^wm.*skullstripped.nii$');

  hdr = spm_vol(anat_normalized_file);
  vol = spm_read_vols(hdr);

  anatRange = [min(vol(:)) max(vol(:))];

end
