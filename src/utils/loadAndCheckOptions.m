% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function opt = loadAndCheckOptions(opt)
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
  % opt = loadAndCheckOptions(opt)
  %
  % if not argument is provived checks in the current directory for
  % ``opt_task-*.json`` files and loads the most recent one by name
  % (using the date- key).
  %
  % then checks the content of the opt structure and adds missing information

  if nargin < 1 || isempty(opt)
    opt = spm_select('FPList', pwd, '^options_task-.*.json$');
  end

  % finds most recent option file
  if size(opt, 1) > 1
    containsDate = cellfun(@any, strfind(cellstr(opt), '_date-'));
    if any(containsDate)
      opt = opt(containsDate, :);
      opt = sortrows(opt);
      opt = opt(end, :);
    end
  end

  if ischar(opt) && size(opt, 1) == 1
    if exist(opt, 'file')
      fprintf(1, '\nReading option from: %s.\n', opt);
      opt = spm_jsonread(opt);
    else
      error('the requested file does not exist: %s', opt);
    end
  end

  % temporary hack to fix the way spm_jsonread reads some empty fields
  % REPORT IT TO SPM
  if isfield(opt, 'subjects') && ~iscell(opt.subjects) && isnan(opt.subjects)
    opt.subjects = {[]};
  end

  opt = checkOptions(opt);
  fprintf(1, '\nOptions are locked & loaded.\n\n');

end
