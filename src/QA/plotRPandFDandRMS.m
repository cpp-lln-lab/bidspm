function F = plotRPandFDandRMS(motion, fd, fdOutliers, rms, rmsOutliers, visible)
  %
  % Plots realignement parameters, framewise displacement, global signal
  %
  % :type  motion:  nX6 array
  % :param motion: motion parameters ([trans_x, trans_y, trans_z, ..
  %                                    rot_x, rot_y, rot__z ])
  %
  % :type  fd:  nX1
  % :param fd: framewise displacement
  %
  % :type  fdOutliers:  nX1 logical
  % :param fdOutliers: framewise displacement outliers
  %
  % :type  rms:  nX1
  % :param rms: root mean square
  %
  % :type  rmsOutliers:  nX1
  % :param rmsOutliers: root mean square outliers
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

  % (C) Copyright 2023 Cyril Pernet
  % (C) Copyright 2023 Remi Gau

  F = spm_figure('Create', 'motionAndFdAndRms', 'Motion and displacement', visible);

  nbVolumes = size(motion, 1);

  subplot(2, 2, 1);
  setSubplot('translation', ...
             'displacement in mm', ...
             nbVolumes);
  plot(motion(:, [1 2 3]), 'LineWidth', 2);

  subplot(2, 2, 2);
  setSubplot('rotation', ...
             'degrees', ...
             nbVolumes);
  plot(motion(:, [4 5 6]), 'LineWidth', 2);

  subplot(2, 2, 3);
  plot(fd, 'LineWidth', 1);
  setSubplot('framewise displacement', ...
             'absolute displacement in mm', ...
             nbVolumes);
  tmp = fdOutliers .* fd;
  tmp(tmp == 0) = NaN;
  plot(tmp, 'ro', 'LineWidth', 3);

  subplot(2, 2, 4);
  plot(rms, 'LineWidth', 1);
  setSubplot('root mean squares', ...
             'Mean square displacement in mm', ...
             nbVolumes);
  tmp = rmsOutliers .* rms;
  tmp(tmp == 0) = NaN;
  plot(tmp, 'ro', 'LineWidth', 3);

end

function setSubplot(thisTitle, yLabel, nbVolumes)
  axis tight;
  box on;
  grid on;
  hold on;
  plot([0 nbVolumes], [0 0], 'k');
  xlabel('Volumes');
  title(thisTitle);
  ylabel(yLabel);
end
