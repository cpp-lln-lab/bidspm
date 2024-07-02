function [filter, opt] = fileFilterForBold(opt, subLabel, type)
  %
  % USAGE::
  %
  %  [filter, opt] = fileFilterForBold(opt, subLabel, type)
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :type opt:  structure
  %
  % :param subLabel:
  % :type subLabel: char
  %
  % :param type: any of {'glm', 'stc', 'confounds', 'events'}
  % :type type: char
  %

  % (C) Copyright 2022 bidspm developers

  if nargin < 2
    subLabel = '';
  end

  if nargin < 3
    type = 'glm';
  end

  opt.query.modality = 'func';

  if strcmp(type, 'glm')
    if isfield(opt.query, 'desc') && ~isempty(opt.query.desc)
    elseif opt.fwhm.func > 0
      opt.query.desc = ['smth' num2str(opt.fwhm.func)];
    else
      opt.query.desc = 'preproc';
    end
  end

  if ischar(opt.space)
    opt.space = cellstr(opt.space);
  end

  opt.query.space = opt.space;
  opt = mniToIxi(opt);

  if ismember(type,  {'stc'})
    % only stick to raw data
    opt.query.space = '';
    opt.query.desc = '';
  end

  filter = opt.bidsFilterFile.bold;
  filter.prefix =  '';
  if ~isempty(subLabel)
    filter.sub =  regexify(subLabel);
  end

  filter.extension = {'.nii.*'};
  if strcmp(type, 'confounds')
    filter.extension = '.tsv';
    filter.suffix = {'regressors', 'timeseries', 'outliers', 'motion'};
  end

  if strcmp(type, 'events')
    filter.extension = '.tsv';
    filter.suffix = {'events'};
  end

  % task details should be passed via opt.query
  % use the extra query options specified in the options
  filter = setFields(filter, opt.query);
  filter = removeEmptyQueryFields(filter);

  % in case task was not passed through opt.query
  if ~isfield(filter, 'task')
    filter.task = opt.taskName;
  end

  if ismember(type, {'events', 'confounds'})
    if isfield(filter, 'space')
      filter = rmfield(filter, 'space');
    end
    if isfield(filter, 'desc')
      filter = rmfield(filter, 'desc');
    end
  end

end
