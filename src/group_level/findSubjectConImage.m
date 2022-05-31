function file = findSubjectConImage(varargin)
  %
  % USAGE::
  %
  %   file = findSubjectConImage(opt, subLabel, contrastName)
  %
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % (C) Copyright 2019 CPP_SPM developers

  args = inputParser;

  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'subLabel', @ischar);
  addRequired(args, 'contrastName', @ischar);

  parse(args, varargin{:});

  opt = args.Results.opt;
  subLabel = args.Results.subLabel;
  contrastName = args.Results.contrastName;

  file = '';

  % FFX directory and load SPM.mat of that subject
  ffxDir = getFFXdir(subLabel, opt);
  load(fullfile(ffxDir, 'SPM.mat'));

  % find which contrast of that subject has the name of the contrast we
  % want to bring to the group level
  conIdx = find(strcmp({SPM.xCon.name}, contrastName));

  if isempty(conIdx)

    msg = sprintf('Skipping subject %s. Could not find a contrast named %s\nin %s.\n', ...
                  subLabel, ...
                  contrastName, ...
                  fullfile(ffxDir, 'SPM.mat'));

    errorHandling(mfilename(), 'missingContrast', msg, true, opt.verbosity);

    printToScreen(['available contrasts:\n' createUnorderedList({SPM.xCon.name}')], ...
                  opt, 'format', 'red');

  else

    % Check which level of CON smoothing is desired
    smoothPrefix = '';
    if opt.fwhm.contrast > 0
      smoothPrefix = [spm_get_defaults('smooth.prefix'), num2str(opt.fwhm.contrast)];
    end

    fileName = sprintf('con_%0.4d.nii', conIdx);
    file = validationInputFile(ffxDir, fileName, smoothPrefix);

  end

end
