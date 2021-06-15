function matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subLabel)
  %
  % Creates a batch to set an anatomical image
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subID)
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param subLabel: subject label
  % :type subLabel: string
  %
  % :returns: :matlabbatch: (structure)
  %
  % matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subID)
  %
  % - image type = opt.anatReference.type (default = T1w)
  % - session to select the anat from = opt.anatReference.session (default = 1)
  %
  % We assume that the first anat of that type is the "correct" one
  %
  % (C) Copyright 2020 CPP_SPM developers

  printBatchName('selecting anatomical image', opt);

  [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);

  matlabbatch{end + 1}.cfg_basicio.cfg_named_file.name = 'Anatomical';
  matlabbatch{end}.cfg_basicio.cfg_named_file.files = { {fullfile(anatDataDir, anatImage)} };

end
