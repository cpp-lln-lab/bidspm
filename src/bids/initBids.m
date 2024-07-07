function initBids(varargin)
  %
  % Initialize a BIDS dataset and updates dataset description.
  %
  % USAGE::
  %
  %   initBids(opt, 'description', '', 'force', false)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %

  % (C) Copyright 2022 bidspm developers

  args = inputParser;

  defaultDesc = '';
  defaultForce = false;

  addRequired(args, 'opt', @isstruct);
  addParameter(args, 'description', defaultDesc, @ischar);
  addParameter(args, 'force', defaultForce, @islogical);

  parse(args, varargin{:});

  opt = args.Results.opt;

  descr_file = fullfile(opt.dir.output, 'dataset_description.json');

  if ~exist(descr_file, 'file') || args.Results.force

    bids.init(opt.dir.output, 'folders', struct(), 'is_derivative', true);

    BIDS = bids.layout(opt.dir.output, ...
                       'use_schema', false, ...
                       'index_derivatives', false, ...
                       'index_dependencies', false, ...
                       'tolerant', true, ...
                       'verbose', opt.verbosity > 0);

    pipeline = opt.pipeline.name;
    if ~strcmp(opt.pipeline.type, '')
      pipeline = [pipeline '-' opt.pipeline.type];
    end
    ds_desc = bids.Description(pipeline, BIDS);

    ds_desc.content.BIDSVersion = getDefaultBIDSVersion();

    ds_desc.content.License = 'CC0';

    ds_desc.content.GeneratedBy{1}.Version = getVersion();
    ds_desc.content.GeneratedBy{1}.CodeURL = returnRepoURL();
    ds_desc.content.GeneratedBy{1}.Description = args.Results.description;

    ds_desc.content.Name = args.Results.description;

    ds_desc.write(opt.dir.output);

  end

  addGitIgnore(opt.dir.output);
  addReadme(opt.dir.output);
  addLicense(opt.dir.output);

end

function version = getDefaultBIDSVersion()
  version = '1.6.0';
end
