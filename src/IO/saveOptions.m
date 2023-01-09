function saveOptions(opt)
  %
  % Saves options in a JSON file in a ``options`` folder.
  %
  % USAGE::
  %
  %   saveOptions(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %

  % (C) Copyright 2020 bidspm developers

  optionDir = fullfile(opt.dir.derivatives, 'options');
  spm_mkdir(optionDir);

  taskString = '';
  if isfield(opt, 'taskName')
    taskString = ['_task-', strjoin(opt.taskName, '')];
  end

  filename = fullfile(optionDir, ['options', taskString, '_', timeStamp(), '.json']);

  bids.util.jsonwrite(filename, opt);

  msg = sprintf('Options saved in: %s', pathToPrint(filename));
  logger('INFO', msg, 'options', opt, 'filename', mfilename());

end
