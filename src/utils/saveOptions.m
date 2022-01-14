function saveOptions(opt)
  %
  % Short description of what the function does goes here.
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

  filename = fullfile(optionDir, [timeStamp(), '_options', ...
                                  taskString, ...
                                  '.json']);

  jsonFormat.indent = '    ';
  spm_jsonwrite(filename, opt, jsonFormat);

  fprintf('Options saved in: %s\n\n', filename);

end
