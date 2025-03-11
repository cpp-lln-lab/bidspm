function transparentMontage(opt)
  %
  % Generate montage with transparent plotting
  %
  % USAGE::
  %
  %   transparentMontage(opt)
  %
  %

  % (C) Copyright 2025 bidspm developers

  for i_node = 1:numel(opt.model.bm.Nodes)

    node = opt.model.bm.Nodes{i_node};

    if any(strcmp(node.Level, {'Run', 'Subject'}))

      for iSub = 1:numel(opt.subjects)

        subLabel = opt.subjects{iSub};

        ffxDir = getFFXdir(subLabel, opt);
        load(fullfile(ffxDir, 'SPM.mat'));

        for iRes = 1:numel(node.Model.Software.bidspm.Results)

          opt.results = node.Model.Software.bidspm.Results{iRes};

          if ~isfield(opt.results, 'montage') || ~opt.results.montage.do
            continue
          end

          % set defaults
          [opt, ~] = checkMontage(opt, iRes, node, struct([]), subLabel);
          opt = checkOptions(opt);
          opt.results(iRes).montage = setMontage(opt.results(iRes));

          for iName = 1:numel(opt.results.name)

            plotTransparentMontage(opt, SPM, subLabel, iRes, iName);

          end

        end

      end

    end

  end

end

function plotTransparentMontage(opt, SPM, subLabel, iRes, iName)

  overwrite = true;

  color_map_folder = fullfile(returnRootDir(), 'lib', 'brain_colours', 'mat_maps');

  ffxDir = getFFXdir(subLabel, opt);

  if opt.results(iRes).binary
    layers = sd_config_layers('init', {'truecolor', 'dual', 'contour'});
  else
    layers = sd_config_layers('init', {'truecolor', 'dual'});
  end

  %% Layer 1: Anatomical map
  layers(1) = setFields(layers(1), opt.results(iRes).sdConfig.layers{1}, overwrite);

  layers(1).color.file = opt.results(iRes).montage.background{1};

  hdr = spm_vol(layers(1).color.file);
  [max_val, ~] = slover('volmaxmin', hdr);
  layers(1).color.range = [0 max_val];

  %% Layer 2: Dual-coded layer

  % - contrast estimates color-coded;
  layers(2) = setFields(layers(2), opt.results(iRes).sdConfig.layers{2}, overwrite);

  name = opt.results.name{iName};
  tmp = struct('name', name);
  contrastNb = getContrastNb(tmp, opt, SPM);
  % keep track if this is a t test or F test
  stat = SPM.xCon(contrastNb).STAT;
  contrastNb = sprintf('%04.0f', contrastNb);

  % - statistics opacity-coded
  if strcmp(stat, 'T')
    colorFile = spm_select('FPList', ffxDir, ['^con_' contrastNb '.nii$']);
    opacityFile = spm_select('FPList', ffxDir, ['^spmT_' contrastNb '.nii$']);

    layers(2).opacity.label = '| t |';

    load(fullfile(color_map_folder, 'diverging_bwr_iso.mat')); %#ok<*LOAD>
    layers(2).color.map = diverging_bwr;
  else
    colorFile = spm_select('FPList', ffxDir, ['^ess_' contrastNb '.nii$']);
    opacityFile = spm_select('FPList', ffxDir, ['^spmF_' contrastNb '.nii$']);

    layers(2).opacity.label = 'F';

    load(fullfile(color_map_folder, '1hot_iso.mat'));
    layers(2).color.map = hot;

    hdr = spm_vol(opacityFile);
    [max_val, ~] = slover('volmaxmin', hdr);
    layers(2).color.range = [0 max_val];

    layers(2).opacity.range = [0 5];
  end
  layers(2).color.file = colorFile;
  layers(2).opacity.file = opacityFile;

  title = strrep(name, '_', ' ');
  layers(2).color.label = [title ' (a.u.)'];

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
  [~, ~, h_figure] = sd_display(layers, settings);

  outputFile = fullfile(ffxDir, [contrastNb '_'  name '.png']);
  print(h_figure, outputFile, '-dpng');
  close(h_figure);

  % TODO
  % rename file

end
