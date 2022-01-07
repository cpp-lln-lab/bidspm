function addStatsDatasetDescription(varargin)
  %
  %
  % USAGE::
  %
  %   addStatsDatasetDescription(opt)
  %
  % :param opt: obligatory argument. Lorem ipsum dolor sit amet,
  % :type opt: structure
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  % The code goes below

  p = inputParser;

  addRequired(p, 'opt', @isstruct);

  parse(p, varargin{:});

  opt = p.Results.opt;

  descr_file = fullfile(opt.dir.output, 'dataset_description.json');
  if ~exist(descr_file, 'file')
    isDerivative = true;
    bids.init(opt.dir.output, struct(), isDerivative);
    ds_desc = bids.Description('cpp_spm-stats', bids.layout(opt.dir.output));
    ds_desc.content.BIDSVersion = '1.6.0';
    ds_desc.content.GeneratedBy{1}.Version = getVersion();
    ds_desc.content.GeneratedBy{1}.CodeURL = getRepoURL();
    ds_desc.content.GeneratedBy{1}.Description = 'subject level statistics';
    ds_desc.write(opt.dir.output);
  end

end
