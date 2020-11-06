% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function saveOptions(opt)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %

  filename = fullfile(pwd, ['options', ...
                            '_task-', opt.taskName, ...
                            '_date-' datestr(now, 'yyyymmddHHMM'), ...
                            '.json']);

  jsonFormat.indent = '    ';
  spm_jsonwrite(filename, opt, jsonFormat);

  fprintf('Options saved in: %s\n\n', filename);

end
