function status = isSkullstripped(bidsFile)
  %
  % Check if the image is skullstripped.
  %
  % USAGE::
  %
  %   status = isSkullstripped(bidsFile)
  %
  % :param bidsFile: bids.File object
  % :type  bidsFile: bids.File
  %
  % :return: status: true if the image is skullstripped
  % :rtype: logical
  %
  % EXAMPLE::
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
