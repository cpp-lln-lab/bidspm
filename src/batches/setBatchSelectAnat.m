function matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subLabel)
  %
  % Creates a batch to set an anatomical image
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch: list of SPM batches
  % :type  matlabbatch: structure
  %
  % :param BIDS: dataset layout.
  %              See: bids.layout, getData.
  %
  % :type  BIDS: structure
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :type  opt: structure
  %
  % :param subLabel: subject label
  % :type  subLabel: char
  %
  % :return: matlabbatch
  % :rtype:  structure
  %
  % matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subLabel)
  %
  % - image ``type = opt.bidsFilterFiler.t1w.suffix`` (default = T1w)
  %
  % - session to select the anat from ``opt.bidsFilterFiler.t1w.ses`` (default = 1)
  %
  % We assume that the first anat of that type is the "correct" one
  %

  % (C) Copyright 2020 bidspm developers

  printBatchName('selecting anatomical image', opt);

  nbImgToReturn = 1;
  if opt.anatOnly
    nbImgToReturn = Inf;
  end
  [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel, nbImgToReturn);

  matlabbatch{end + 1}.cfg_basicio.cfg_named_file.name = 'Anatomical';
  if ischar(anatImage)
    matlabbatch{end}.cfg_basicio.cfg_named_file.files = { {fullfile(anatDataDir, anatImage)} };
  else
    matlabbatch{end}.cfg_basicio.cfg_named_file.files = { fullfile(anatDataDir, anatImage) };
  end

end
