function cliCopy(varargin)
  % Copy the content of the fmriprep directory to the output directory.
  %
  % Type ``bidspm help`` for more info.
  %

  % (C) Copyright 2023 bidspm developers
  args = inputParserForCopy();
  try
    parse(args, varargin{:});
  catch ME
    displayArguments(varargin{:});
    rethrow(ME);
  end

  opt = getOptionsFromCliArgument(args);
  opt.pipeline.type = 'preproc';

  opt = checkOptions(opt);

  bidsFilterFile = getBidsFilterFile(args);

  if isempty(opt.taskName)
    opt = rmfield(opt, 'taskName');
  end

  if isempty(bidsFilterFile)
    opt.query.desc = {'preproc', 'brain'};

    opt.query.suffix = {'T1w',  'mask', 'bold', 'events'};

    if opt.anatOnly
      opt.query.suffix = {'T1w', 'mask'};
    end

    opt.query.space = opt.space;

    saveOptions(opt);

    bidsCopyInputFolder(opt, 'unzip', true, 'force', args.Results.force);

  else

    suffixes = fieldnames(bidsFilterFile);
    for i = 1:numel(suffixes)

      if opt.anatOnly && ~strcmp(bidsFilterFile.(suffixes{i}).modality, 'anat')
        continue
      end

      opt.query = bidsFilterFile.(suffixes{i});

      saveOptions(opt);

      bidsCopyInputFolder(opt, 'unzip', true, 'force', args.Results.force);

    end

  end

end
