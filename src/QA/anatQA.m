function [json, fig] = anatQA(varargin)
  %
  % anatomical QA measures from the
  % *Preprocessed Connectome Project Quality Assurance Protocol (QAP)*
  % <http://preprocessed-connectomes-project.org/quality-assessment-protocol/>
  %
  % EXAMPLE::
  %
  %     [json, fig] = anatQA(anatImageFile, grayMatterFile, whiteMatterFile, ...
  %                          'noBackground', true, 'visible', 'on')
  %
  %
  % :param anatImageFile:
  % :type  anatImageFile: valid file path
  %
  % :param grayMatterFile: gray matter probabilistic segmentation
  % :type  grayMatterFile: valid file path
  %
  % :param whiteMatterFile: white matter probabilistic segmentation
  % :type  whiteMatterFile: valid file path
  %
  % :param noBackground:
  % :type  noBackground: logical
  %
  % :type  visible: char
  % :param visible: figure visibility. Any of: ``'off'``, ``'on'``
  %
  % OUTPUT
  %
  % fig is a spm figure handle
  %
  % json is a structure with the following fields:
  %
  % - SNR : the signal-to-Noise Ratio.
  %         That is: the mean intensity within gray
  %         and white matter divided by the standard deviation
  %         of the values outside the brain.
  %         Higher values are better.
  %
  % - CNR : the Contrast to Noise Ratio.
  %         That is: the mean of the white matter intensity values
  %         minus the mean of the gray matter intensity values
  %         divided by the standard deviation
  %         of the values outside the brain.
  %         Higher values are better.
  %
  % - FBER: Foreground to Background Energy Ratio,
  %         That is: the variance of voxels in grey and white matter
  %         divided by the variance of voxels outside the brain.
  %         Higher values are better.
  %
  % - EFC : Entropy Focus Criterion,
  %         That is: the entropy of voxel intensities proportional
  %         to the maximum possible entropy for a similarly sized image.
  %         Indicates ghosting and head motion-induced blurring.
  %         Lower values are better.
  %         See <http://ieeexplore.ieee.org/document/650886/>
  %
  % .. note::
  %
  %   When the background has 0 variance
  %   (e.g. a sequence with noise suppression like FLAIR)
  %   then the standard  deviation of the white matter
  %   is used as reference instead of the background
  %
  %   GM and WM are thresholded by making them mutually exclusive.
  %   The background is found using data outside a large brain mask
  %   and trimming extreme values.
  %
  % Adapted from Cyril Pernet's spmup

  % (C) Copyright 2017-2023 Cyril Pernet
  % (C) Copyright 2023 Remi Gau

  isFile = @(x) exist(x, 'file') == 2;

  args = inputParser;

  addRequired(args, 'anatImageFile', isFile);
  addRequired(args, 'grayMatterFile', isFile);
  addRequired(args, 'whiteMatterFile', isFile);
  addParameter(args, 'noBackground', true, @islogical);
  addParameter(args, 'visible', 'on', @(x) ismember(lower(x), {'on', 'off'}));

  parse(args, varargin{:});

  anatFile = args.Results.anatImageFile;
  gmFile = args.Results.grayMatterFile;
  wmFile = args.Results.whiteMatterFile;
  noBackground = args.Results.noBackground;
  visible = args.Results.visible;

  files = char({anatFile, gmFile, wmFile});
  headers = spm_vol(files);
  spm_check_orientations(spm_vol(files));

  % define a large brain mask making sure the background has nothing but background in it
  brainMask = (smooth3(spm_read_vols(headers(2)), 'box', 25) + ...
               smooth3(spm_read_vols(headers(3)), 'box', 25)) > 0.1;
  [x, y, z] = ind2sub(headers(1).dim, find(brainMask == 0));
  data = sort(spm_get_data(headers(1), [x y z]'));

  if isempty(data)
    logger('ERROR', ...
           sprintf('no background data were obtained from the brain mask from image:\n %s.', ...
                   anatFile));
  end

  fig = plotAnatQA(headers(1), brainMask, data, visible);

  % compute the noise level using and 50% trimmed data (remove extreme values)
  data(isnan(data)) = [];
  up                = median(data) + iqr(data) / 2;
  down              = median(data) - iqr(data) / 2;
  index             = logical((data < up) .* (data > down));
  stdNonbrain      = std(data(index));
  if stdNonbrain == 0
    noBackground = 0;
  end

  %% now do all computations
  % make gray/white mutually exclusive
  I_GM = spm_read_vols(headers(2))  > spm_read_vols(headers(3));
  I_WM = spm_read_vols(headers(3)) > spm_read_vols(headers(2));

  % compute taking voxels in I_GM and I_WM
  clear x y z;
  [x, y, z] = ind2sub(headers(1).dim, find(I_GM));
  dataGM  = spm_get_data(headers(1), [x y z]');
  meanGM  = mean(dataGM);

  clear x y z;
  [x, y, z] = ind2sub(headers(1).dim, find(I_WM));
  dataWM  = spm_get_data(headers(1), [x y z]');
  meanWM  = mean(dataWM);

  json.SNR  = ((meanGM + meanWM) / 2) / stdNonbrain;
  json.CNR  = (meanWM - meanGM) / stdNonbrain;
  json.FBER = var([dataGM dataWM]) / stdNonbrain^2;
  if noBackground == 0
    json.SNR  = ((meanGM + meanWM) / 2) / std(dataWM);
    json.CNR  = (meanWM - meanGM) / std(dataWM);
    json.FBER = var([dataGM dataWM]) / std(dataWM)^2;
  end

  data = spm_read_vols(headers(1));
  data(isnan(data)) = [];
  Bmax = sqrt(sum(data(:).^2));
  try
    % should work most of the time, possibly throwing warnings (cf Joost Kuijer)
    tmp = (data(:) ./ Bmax) .* log(data(:) ./ Bmax);
  catch
    tmp = (data(:) ./ Bmax) .* abs(log(data(:) ./ Bmax));
  end
  json.EFC = real(bids.internal.nansum(tmp));

end

function fig = plotAnatQA(anatHeader, brainMask, data, visible)

  fig = spm_figure('Create', 'brainMask', 'Brain Mask', visible);

  if bids.internal.is_octave()
    return
  end

  % make a figure showing the mask and the data range

  up = median(data) + iqr(data) / 2;
  down = median(data) - iqr(data) / 2;

  tmp = spm_read_vols(anatHeader); % read anat
  tmp = tmp ./ max(tmp(:)) * 100; % nornalize to 100
  tmp(brainMask == 0) = 200; % set non brain to 200

  subplot(2, 2, 1);
  imagesc(fliplr(squeeze(tmp(:, :, round(anatHeader.dim(3) / 2))))');
  title('brain mask - sagital');

  subplot(2, 2, 2);
  imagesc(flipud(squeeze(tmp(:, round(anatHeader.dim(2) / 2), :))'));
  title('brain mask - axial');

  subplot(2, 2, 4);
  imagesc(flipud(squeeze(tmp(round(anatHeader.dim(1) / 2), :, :))'));
  title('brain mask - coronal');
  clear tmp;

  subplot(2, 2, 3);
  hold on;

  k = round(1 + log2(length(data)));
  histogram(data, k, ...
            'FaceColor', [1 1 0], ...
            'EdgeColor', [1 1 0], ...
            'FaceAlpha', 0.8);
  plot(repmat(down, max(hist(data, k)), 1), ...
       1:max(hist(data, k)), ...
       'k', 'LineWidth', 3);
  plot(repmat(up,  max(hist(data, k)),  1), ...
       1:max(hist(data, k)), ...
       'k', 'LineWidth', 3);

  [x, y, z] = ind2sub(anatHeader.dim, find(brainMask));
  histogram(spm_get_data(anatHeader, [x y z]'), k, ...
            'FaceColor', [0 0 1], ...
            'EdgeColor', [0 0 1], ...
            'FaceAlpha', 0.4);
  title('background voxels & limits vs brain mask');
  axis tight;
  box on;
  grid on;

end
