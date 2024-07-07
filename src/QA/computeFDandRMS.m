function [fd, rms] = computeFDandRMS(motionParameters, radius)
  %
  % Compute framewise displacement as a sum (FD) and RMS.
  %
  % USAGE::
  %
  %         [FD,RMS] = computeFDandRMS(motionParameters, radius)
  %
  % :type  motion:  nX6 array
  % :param motion: motion parameters ([trans_x, trans_y, trans_z, ..
  %                                    rot_x, rot_y, rot__z ])
  %
  % :type  radius:  nX6 array
  % :param radius: brain radius
  %
  % Power et al. (2012) doi:10.1016/j.neuroimage.2011.10.018
  % Power et al. (2014) doi:10.1016/j.neuroimage.2013.08.048
  %
  % See also: plotRPandFDandRMS, getDist2surf
  %
  % Adapted from Cyril Pernet's spmup
  %

  % (C) Copyright 2023 Cyril Pernet
  % (C) Copyright 2023 Remi Gau

  if nargin < 2
    radius  = 50;
  end

  %% read
  % de-mean and detrend
  motion = spm_detrend(motionParameters, 1);
  % angle in radian by average head size = displacement in mm
  motion(:, [4 5 6]) = motion(:, [4 5 6]) .* radius;

  %% compute
  D = diff(motion, 1, 1);
  D = [zeros(1, 6); D];
  % framewise displacement a la Powers
  fd  = sum(abs(D), 2);
  % root mean square for each column a la Van Dijk
  rms = sqrt(mean(detrend(D).^2, 2));

end
