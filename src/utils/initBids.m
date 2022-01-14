function initBids(varargin)
  %
  % Initialize a BIDS dataset and updates dataset description.
  %
  % USAGE::
  %
  %   initBids(opt, 'description', '', 'force', false)
  %
  % :param opt: obligatory argument.
  % :type opt: structure
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  default_desc = '';
  default_force = false;

  addRequired(p, 'opt', @isstruct);
  addParameter(p, 'description', default_desc, @ischar);
  addParameter(p, 'force', default_force, @islogical);

  parse(p, varargin{:});

  opt = p.Results.opt;

  descr_file = fullfile(opt.dir.output, 'dataset_description.json');

  if ~exist(descr_file, 'file') || p.Results.force

    isDerivative = true;

    bids.init(opt.dir.output, struct(), isDerivative);

    use_schema = false;
    index_derivatives = false;
    tolerant = true;
    verbose = opt.verbosity > 0;
    BIDS = bids.layout(opt.dir.output, use_schema, index_derivatives, tolerant, verbose);

    pipeline = opt.pipeline.name;
    if ~strcmp(opt.pipeline.type, '')
      pipeline = [pipeline '-' opt.pipeline.type];
    end
    ds_desc = bids.Description(pipeline, BIDS);

    ds_desc.content.BIDSVersion = getDefaultBIDSVersion();

    ds_desc.content.GeneratedBy{1}.Version = getVersion();
    ds_desc.content.GeneratedBy{1}.CodeURL = returnRepoURL();
    ds_desc.content.GeneratedBy{1}.Description = p.Results.description;

    ds_desc.content.Name = p.Results.description;

    ds_desc.write(opt.dir.output);

  end

end

function version = getDefaultBIDSVersion()
  version = '1.6.0';
end
