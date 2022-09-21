function status = skullstrippingAlreadyDone(anatFile, BIDS)
  %
  % USAGE::
  %
  %     status = skullstripAlreadyDone(anatFile, BIDS, opt)
  %
  % :param anatFile:
  % :type anatFile: path
  %
  % :returns: returns true
  %
  % to skip skullstripping if done previously
  %
  %
  %

  % (C) Copyright 2022 bidspm developers

  anatFile = bids.File(anatFile);
  filter = anatFile.entities;
  filter.modality = 'anat';

  filter.suffix = anatFile.suffix;
  filter.desc = 'brain';
  filter.suffix = 'mask';
  skullstrippedImage = bids.query(BIDS, 'data', filter);

  status = ~isempty(skullstrippedImage);

end
