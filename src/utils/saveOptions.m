function saveOptions(opt)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % (C) Copyright 2020 CPP_SPM developers

  optionDir = fullfile(pwd, 'cfg');
  [~, ~, ~] = mkdir(optionDir);

  taskString = '';
  if isfield(opt, 'taskName')
    taskString = ['_task-', opt.taskName];
  end

  filename = fullfile(optionDir, ['options', ...
                                  taskString, ...
                                  '_date-' datestr(now, 'yyyymmddHHMM'), ...
                                  '.json']);

  jsonFormat.indent = '    ';
  spm_jsonwrite(filename, opt, jsonFormat);

  fprintf('Options saved in: %s\n\n', filename);

end
