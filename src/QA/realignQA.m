function [confoundsTsv, figureHandle] = realignQA(varargin)
  %
  % implement different quality control fMRI realigned
  %
  % [confoundsTsv, figureHandle] = realignQA(boldFile, motionFile, ...
  %                                          'radius', 50, ...
  %                                          'visible', 'on')
  %
  %
  % Adapted from Cyril Pernet's spmup

  % (C) Copyright 2019-2023 Cyril Pernet
  % (C) Copyright 2023 Remi Gau

  isFile = @(x) exist(x, 'file') == 2;

  args = inputParser;

  addRequired(args, 'boldFile', isFile);
  addRequired(args, 'motionFile', isFile);
  addParameter(args, 'radius', 50, @(x) x > 0);
  addParameter(args, 'visible', 'on', @(x) ismember(lower(x), {'on', 'off'}));

  parse(args, varargin{:});

  boldFile = args.Results.boldFile;
  motionFile = args.Results.motionFile;
  radiusCm = args.Results.radius;
  visible = args.Results.visible;

  if strcmp(spm_file(motionFile, 'ext'), 'txt')
    motionParameters = load(motionFile);
  end

  [fd, rms] = computeFDandRMS(motionParameters, radiusCm);

  boldHeaders = spm_vol(boldFile);
  glo = computeGlobals(boldHeaders);

  % we do not censor the motion parameters
  % but we keep them for the design
  data = [fd rms glo];
  censoring_regressors = censoring(data);

  % compute volterra
  D      = diff(motionParameters, 1, 1); % 1st order derivative
  D      = [zeros(1, 6); D];  % set first row to 0
  motion = [motionParameters D motionParameters.^2 D.^2];

  confounds = [motion data];

  headers = columnHeaders();
  for i = 1:numel(headers)
    confoundsTsv.(headers{i}) = confounds(:, i);
  end
  for i = 1:size(censoring_regressors, 2)
    confoundsTsv.(sprintf('outlier_%04.0f', i)) = censoring_regressors(:, i);
  end

  figureHandle = plotConfounds(confoundsTsv, visible);

end

function value = columnHeaders()

  value = {'trans_x'; ...
           'trans_y'; ...
           'trans_z'; ...
           'rot_x'; ...
           'rot_y'; ...
           'rot_z'; ...
           'trans_x_derivative1'; ...
           'trans_y_derivative1'; ...
           'trans_z_derivative1'; ...
           'rot_x_derivative1'; ...
           'rot_y_derivative1'; ...
           'rot_z_derivative1'; ...
           'trans_x_power2'; ...
           'trans_y_power2'; ...
           'trans_z_power2'; ...
           'rot_x_power2'; ...
           'rot_y_power2'; ...
           'rot_z_power2'; ...
           'trans_x_derivative1_power2'; ...
           'trans_y_derivative1_power2'; ...
           'trans_z_derivative1_power2'; ...
           'rot_x_derivative1_power2'; ...
           'rot_y_derivative1_power2'; ...
           'rot_z_derivative1_power2'; ...
           'framewise_displacement'; ...
           'rms'; ...
           'global_signal'};

end

function glo = computeGlobals(V)
  glo = zeros(length(V), 1);
  for s = 1:length(V)
    glo(s) = spm_global(V(s));
  end
  % since in spm the data are detrended
  glo = spm_detrend(glo, 1);
end
