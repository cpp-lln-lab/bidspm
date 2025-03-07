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

opt.pipeline.type = 'stats';

opt.dir.raw = fullfile(this_dir, 'inputs', 'raw');
opt.dir.derivatives = fullfile(this_dir, 'outputs', 'derivatives');
opt.dir.preproc = fullfile(opt.dir.derivatives, 'bidspm-preproc');

opt.dir.roi = fullfile(opt.dir.derivatives, 'bidspm-roi');
opt.dir.stats = fullfile(opt.dir.derivatives, 'bidspm-stats');

opt.model.file = fullfile(this_dir, 'models', 'model-MoAE_smdl.json');

opt.subjects = {'01'};

% read the model
opt = checkOptions(opt);

% TODO loop over noce and subjects

overwrite = true;

color_map_folder = fullfile(returnRootDir(), 'lib', 'brain_colours', 'mat_maps');

node = opt.model.bm.Nodes{1};

if any(strcmp(node.Level, {'Run', 'Subject'}))
    
    for iSub = 1:numel(opt.subjects)
        
        subLabel = opt.subjects{iSub};
        
        ffxDir = getFFXdir(subLabel, opt);
        load(fullfile(ffxDir, 'SPM.mat'))

        for iRes = 1:numel(node.Model.Software.bidspm.Results)
            
            opt.results = node.Model.Software.bidspm.Results{iRes};
            
            if ~isfield(opt.results, 'montage') || ~opt.results.montage.do
                continue
            end
            
            % set defaults
            [opt, ~] = checkMontage(opt, iRes, node, struct([]), subLabel);
            opt = checkOptions(opt);
            opt.results(iRes).montage = setMontage(opt.results(iRes));
            
            for i_name =1:numel(opt.results.name)
                
                if opt.results(iRes).binary
                    layers = sd_config_layers('init', {'truecolor', 'dual', 'contour'});
                else
                    layers = sd_config_layers('init', {'truecolor', 'dual'});
                end
                
                %% Layer 1: Anatomical map
                layers(1) = setFields(layers(1), opt.results(iRes).sdConfig.layers{1}, overwrite);
                
                layers(1).color.file = opt.results(iRes).montage.background{1};
                
                hdr = spm_vol(layers(1).color.file);
                [max_val, min_val] = slover('volmaxmin', hdr);
                layers(1).color.range = [0 max_val];
                
                %% Layer 2: Dual-coded layer
                
                % - contrast estimates color-coded;
                layers(2) = setFields(layers(2), opt.results(iRes).sdConfig.layers{2}, overwrite);
                
                name = opt.results.name{i_name};
                tmp = struct('name', name);
                contrastNb = getContrastNb(tmp, opt, SPM);
                
                % keep track if this is a t test or F test
                stat = SPM.xCon(contrastNb).STAT;
                
                contrastNb = sprintf('%04.0f', contrastNb);
                
                if strcmp(stat, 'T')
                    colorFile = spm_select('FPList', ffxDir, ['^con_' contrastNb '.nii$']);
                else
                    colorFile = spm_select('FPList', ffxDir, ['^ess_' contrastNb '.nii$']);
                end
                layers(2).color.file = colorFile;
                
                title = strrep(name, '_', ' ');
                layers(2).color.label = [title ' (a.u.)'];
                
                % - statistics opacity-coded
                if strcmp(stat, 'T')
                    opacityFile = spm_select('FPList', ffxDir, ['^spmT_' contrastNb '.nii$']);
                    
                    layers(2).opacity.label = '| t |';
                    
                    load(fullfile(color_map_folder, 'diverging_bwr_iso.mat'));
                    layers(2).color.map = diverging_bwr;
                else
                    opacityFile = spm_select('FPList', ffxDir, ['^spmF_' contrastNb '.nii$']);
                    
                    layers(2).opacity.label = 'F';
                    
                    load(fullfile(color_map_folder, '1hot_iso.mat'));
                    layers(2).color.map = hot;
                    
                    hdr = spm_vol(opacityFile);
                    [max_val, min_val] = slover('volmaxmin', hdr);
                    layers(2).color.range = [0 max_val];
                    
                    layers(2).opacity.range = [0 5];
                end
                layers(2).opacity.file = opacityFile;
                
                %% Contour
                if opt.results(iRes).binary
                    layers(3) = setFields(layers(3), opt.results(iRes).sdConfig.layers{3}, overwrite);
                    contour = spm_select('FPList', ffxDir, ['^sub.*' contrastNb '.*_mask.nii']);
                    layers(3).color.file = contour;
                end
                
                %% Settings
                settings = opt.results(iRes).sdConfig.settings;
                
                % we reuse the details for the SPM montage
                settings.slice.disp_slices = opt.results(1).montage.slices;
                settings.slice.orientation = opt.results(1).montage.orientation;
                
                settings.fig_specs.title = title;
                
                %% Display the layers
                [settings, p] = sd_display(layers, settings);
                
            end
            
        end
        
    end
end