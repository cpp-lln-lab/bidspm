function [name, version] = generatedBy(BIDS)
  %
  %  Get pipeline info
  %
  % USAGE::
  %
  %     [name, version] = generatedBy(BIDS)
  %
  %
  % :param BIDS: output of bids.layout
  % :type BIDS: struct
  %
  % (C) Copyright 2022 CPP_SPM developers

  name = 'unknown';
  version = 'unknown';

  % for support of old fmriprep dataset
  if ismember('PipelineDescription', fieldnames(BIDS.description))
    GeneratedBy = BIDS.description.PipelineDescription;
  elseif ismember('GeneratedBy', fieldnames(BIDS.description))
    GeneratedBy = BIDS.description.GeneratedBy;
  else
    return
  end

  if isfield(GeneratedBy, 'Name')
    name = GeneratedBy.Name;
  end
  if isfield(GeneratedBy, 'Version')
    version = GeneratedBy.Version;
  end

end
