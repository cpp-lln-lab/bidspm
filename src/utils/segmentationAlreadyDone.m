function status = segmentationAlreadyDone(anatFile, BIDS)
  %
  % USAGE::
  %
  %     status = checkForPreviousSegmentOutput(anatFile, BIDS, opt)
  %
  % :param anatFile:
  % :type anatFile: path
  %
  % :returns: returns true
  %
  % to skip segmentation if done previously
  %
  %
  %

  % (C) Copyright 2022 bidspm developers

  anatFile = bids.File(anatFile);
  filter = anatFile.entities;
  filter.modality = 'anat';

  filter.suffix = anatFile.suffix;
  filter.desc = 'biascor';
  filter.space = 'individual';
  biasCorrectedImage = bids.query(BIDS, 'data', filter);

  filter.suffix = 'probseg';
  filter = rmfield(filter, 'desc');
  tpm = bids.query(BIDS, 'data', filter);

  status = numel(tpm) >= 3 && ~isempty(biasCorrectedImage);

end
