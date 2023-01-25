function fig = plotConfounds(confounds, visible)
  %
  % Plots realignement parameters, framewise displacement, global signal
  %
  % :type  confounds:  nXm array
  % :param confounds:  confounds
  %
  % :type  visible:  char
  % :param visible: figure visibility. Any of: ``'off'``, ``'on'``
  %
  % RETURNS:
  %
  % - F: spm figure handle
  %
  % See also: computeFDandRMS
  %
  % Adapted from Cyril Pernet's spmup

  % (C) Copyright 2017-2023 Cyril Pernet
  % (C) Copyright 2023 Remi Gau

  nbVolumes = size(confounds, 1);

  fig = spm_figure('Create', 'confounds_figure', 'confounds_figure', visible);

  translations = getData(confounds, {'trans_x', 'trans_y', 'trans_z'});
  rotations = getData(confounds, {'rot_x', 'rot_y', 'rot_z'});
  fd = getData(confounds, {'framewise_displacement'});
  rms = getData(confounds, {'rms'});
  global_signal = getData(confounds, {'global_signal'});

  nbSubplots = sum(~cellfun('isempty', {translations, ...
                                        rotations, ...
                                        fd, ...
                                        rms, ...
                                        global_signal}));

  iSubplot = 1;

  subplot(nbSubplots, 1, iSubplot);
  setSubplot('translations', ...
             'mm', ...
             nbVolumes);
  plot(translations, 'LineWidth', 2);
  iSubplot = iSubplot + 1;

  subplot(nbSubplots, 1, iSubplot);
  setSubplot('rotations', ...
             'degrees', ...
             nbVolumes);
  plot(rotations, 'LineWidth', 2);
  iSubplot = iSubplot + 1;

  if ~isempty(fd)
    subplot(nbSubplots, 1, iSubplot);
    plot(fd, 'LineWidth', 1);
    setSubplot('framewise displacement', ...
               'mm', ...
               nbVolumes);
    tmp = computeRobustOutliers(fd) .* fd;
    tmp(tmp == 0) = NaN;
    plot(tmp, 'ro', 'LineWidth', 3);
    iSubplot = iSubplot + 1;
  end

  if ~isempty(rms)
    subplot(nbSubplots, 1, iSubplot);
    plot(rms, 'LineWidth', 1);
    setSubplot('root mean squares', ...
               'mm', ...
               nbVolumes);
    tmp = computeRobustOutliers(rms, 'outlierType', 's-outliers') .* rms;
    tmp(tmp == 0) = NaN;
    plot(tmp, 'ro', 'LineWidth', 3);
    iSubplot = iSubplot + 1;
  end

  if ~isempty(global_signal)
    subplot(nbSubplots, 1, iSubplot);
    plot(global_signal, 'LineWidth', 1);
    setSubplot('global intensity', ...
               'mean intensity', ...
               nbVolumes);
    tmp = computeRobustOutliers(global_signal) .* global_signal;
    tmp(tmp == 0) = NaN;
    plot(tmp, 'ro', 'LineWidth', 3);
  end

  xlabel('Volumes');

end

function data = getData(confounds, cols)
  data = [];
  for i = 1:numel(cols)
    if isfield(confounds, cols{i})
      data(:, i) = confounds.(cols{i}); %#ok<*AGROW>
    end
  end
end

function setSubplot(thisTitle, yLabel, nbVolumes)
  axis tight;
  box on;
  grid on;
  hold on;
  plot([0 nbVolumes], [0 0], 'k');
  title(thisTitle);
  ylabel(yLabel);
end
