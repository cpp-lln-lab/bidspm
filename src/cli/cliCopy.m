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

  opt.query.desc = {'preproc', 'brain'};
  opt.query.suffix = {'T1w', 'bold', 'mask'};
  if opt.anatOnly
    opt.query.suffix = {'T1w', 'mask'};
  end
  if isempty(opt.taskName)
    opt = rmfield(opt, 'taskName');
  end
  opt.query.space = opt.space;

  bidsFilterFile = getBidsFilterFile(args);

  if ~isempty(bidsFilterFile)
    suffixes = fieldnames(bidsFilterFile);
    modalities = {};
    for i = 1:numel(suffixes)
      modalities{end + 1} = bidsFilterFile.(suffixes{i}).modality; %#ok<*AGROW>
      if isfield(bidsFilterFile.(suffixes{i}), 'suffix')
        opt.query.suffix = cat(2, ...
                               opt.query.suffix, ...
                               bidsFilterFile.(suffixes{i}).suffix);
      end
      if isfield(bidsFilterFile.(suffixes{i}), 'desc')
        opt.query.desc = cat(2, ...
                             opt.query.desc, ...
                             bidsFilterFile.(suffixes{i}).desc);
      end
    end
    opt.query.modality = unique(modalities);
  end
  opt.query.suffix = unique(opt.query.suffix);
  opt.query.desc = unique(opt.query.desc);

  saveOptions(opt);

  bidsCopyInputFolder(opt, 'unzip', true, 'force', args.Results.force);

end
