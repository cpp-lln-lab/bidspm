function saveOptions(opt)
  %
  % Saves options in a JSON file in a ``cfg`` folder.
  %
  % USAGE::
  %
  %   saveOptions(opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % (C) Copyright 2020 CPP_SPM developers

  optionDir = fullfile(pwd, 'cfg');
  [~, ~, ~] = mkdir(optionDir);

  taskString = '';
  if isfield(opt, 'taskName')
    taskString = ['_task-', strjoin(opt.taskName, '')];
  end

  filename = fullfile(optionDir, ['options', taskString, '_', timeStamp(), '.json']);

  jsonFormat.indent = '    ';
  spm_jsonwrite(filename, opt, jsonFormat);

  printToScreen(sprintf('Options saved in: %s\n\n', filename), opt);

end
