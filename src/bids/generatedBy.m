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

  name = '';
  version = '';

  % for support of old fmriprep dataset
  if ismember(fieldnames(BIDS.description), 'PipelineDescription')
    GeneratedBy = BIDS.description.PipelineDescription;
  end
  if ismember(fieldnames(BIDS.description), 'GeneratedBy')
    GeneratedBy = BIDS.description.GeneratedBy;
  end

  if isfield(GeneratedBy, 'Name')
    name = GeneratedBy.Name;
  end
  if isfield(GeneratedBy, 'Version')
    version = GeneratedBy.Version;
  end

end
