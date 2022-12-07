function file = findSubjectConImage(varargin)
  %
  % Returns the fullpath of a con image(s)
  % for a given subject label and contrast name(s).
  %
  % USAGE::
  %
  %   file = findSubjectConImage(opt, subLabel, contrastName)
  %
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % :param subLabel:
  % :type subLabel: char
  %
  % :param contrastName:
  % :type contrastName: char or cellstr
  %
  %
  % :returns: - file : a fullpath or a cellstrng of fullpath
  %
  %

  % (C) Copyright 2022 bidspm developers

  file = {};

  isCharOrCellStr = @(x) ischar(x) || iscellstr(x);

  args = inputParser;

  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'subLabel', @ischar);
  addRequired(args, 'contrastName', isCharOrCellStr);

  parse(args, varargin{:});

  opt = args.Results.opt;
  subLabel = args.Results.subLabel;
  contrastName = args.Results.contrastName;

  if ischar(contrastName)
    contrastName = cellstr(contrastName);
  end

  % FFX directory and load SPM.mat of that subject
  ffxDir = getFFXdir(subLabel, opt);
  load(fullfile(ffxDir, 'SPM.mat'));

  printToScreen(sprintf('\n\nFor subject: %s', subLabel), opt);

  for iCon = 1:numel(contrastName)

    % find which contrast of that subject has the name of the contrast
    % we want to bring to the group level
    conIdx = find(strcmp({SPM.xCon.name}, contrastName{iCon}));

    if isempty(conIdx)

      msg = sprintf(['\n\nSkipping subject %s. ', ...
                     'Could not find a contrast named %s\nin %s.\n'], ...
                    subLabel, ...
                    contrastName{iCon}, ...
                    pathToPrint(fullfile(ffxDir, 'SPM.mat')));

      errorHandling(mfilename(), 'missingContrast', msg, true, opt.verbosity);

      printToScreen(['available contrasts:\n' createUnorderedList({SPM.xCon.name}')], ...
                    opt, 'format', 'red');

      file{iCon, 1} = '';

    else

      % Check which level of CON smoothing is desired
      smoothPrefix = '';
      if opt.fwhm.contrast > 0
        smoothPrefix = [spm_get_defaults('smooth.prefix'), num2str(opt.fwhm.contrast)];
      end

      fileName = sprintf('con_%0.4d.nii', conIdx);
      fileName = validationInputFile(ffxDir, fileName, smoothPrefix);

      msg = sprintf('\ncontrast "%s" in image:\n\t%s',  ...
                    contrastName{iCon}, ...
                    pathToPrint(fileName));
      printToScreen(msg, opt);

      file{iCon, 1} = fileName;

    end

  end

  if numel(file) == 1
    file = file{1};
  end

end
