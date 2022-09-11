function status = isSkullstripped(bidsFile)
  %
  % USAGE::
  %
  %   status = isSkullstripped(bidsFile)
  %
  % bidsFile is a bids.File object
  %
  % EXAMPLE
  %
  %     bf = bids.File('sub-01_T1w', 'use_schema', false);
  %
  %     status = isSkullstripped(bf)
  %
  %
  % (C) Copyright 2022 bidspm developers

  status = false;

  metadata = bidsFile.metadata;

  if isfield(bidsFile.entities, 'desc') && strcmp(bidsFile.entities.desc, 'skullstripped')
    status = true;
  elseif ~isempty(metadata) && isfield(metadata, 'SkullStripped') &&  metadata.SkullStripped
    status = true;
  end

end
