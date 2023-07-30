function cliCopy(varargin)
  %
  % Copy the content of the fmripre directory to the output directory.
  %

  % TODO check if

  % (C) Copyright 2022 bidspm developers
  args = inputParserForCopy();
  parse(args, varargin{:});

  opt = getOptionsFromCliArgument(args);

  opt.pipeline.type = 'preproc';
  opt = checkOptions(opt);

  saveOptions(opt);

  opt.query.desc = {'preproc', 'brain'};
  opt.query.suffix = {'T1w', 'bold', 'mask'};
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

  bidsCopyInputFolder(opt, 'unzip', true, 'force', args.Results.force);

end
