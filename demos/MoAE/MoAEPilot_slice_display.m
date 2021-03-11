FWHM = 6;

sd_dir      = fileparts(which('sd_display'));

load(fullfile(sd_dir,'colormaps.mat'));

layers                              = sd_config_layers('init',{'truecolor','dual','contour'});
settings                            = sd_config_settings('init');

opt = MoAEpilot_getOption();

[BIDS, opt] = getData(opt);


for iSub = 1:numel(opt.subjects)
    
    subLabel = opt.subjects{iSub};
    
    ffxDir = getFFXdir(subLabel, FWHM, opt);
    
    % Step 2: Define layers
    % ------------------------------------------------------------------------------
    
    % Layer 1: Anatomical map
    layers(1).color.file                = opt.result.Steps(1).Output.montage.background;
    layers(1).color.map                 = gray(256);
    
    % Layer 2: Dual-coded layer (contrast estimates color-coded; t-statistics
    % opacity-coded)
    layers(2).color.file                = fullfile(ffxDir,'con_0001.nii');
    layers(2).color.map                 = CyBuGyRdYl;
    layers(2).color.label               = '\beta_{faces} - \beta_{baseline} (a.u.)';
    layers(2).opacity.file              = fullfile(ffxDir,'spmT_0001.nii');
    layers(2).opacity.label             = '| t |';
    layers(2).opacity.range             = [0 5.77];
    
    % Layer 3: Contour of significantly activated voxels
    layers(3).color.file                = fullfile(ffxDir,'spmT_0001_listening_p-0050_k-0_MC-FWE_mask.nii');
    
    % Specify settings
    settings.slice.orientation          = opt.result.Steps(1).Output.montage.orientation;
    settings.slice.disp_slices          = opt.result.Steps(1).Output.montage.slices;
    settings.fig_specs.n.slice_column   = 3;
    settings.fig_specs.title            = opt.result.Steps(1).Contrasts(1).Name;
    
    % Display the layers
    [settings,p] = sd_display(layers,settings);
    
end