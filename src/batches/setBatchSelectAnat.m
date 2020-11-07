% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subID)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param argin3: Options chosen for the analysis. See ``checkOptions()``.
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subID)
  %
  % Creates a batch to set an anat image
  % - image type = opt.anatReference.type (default = T1w)
  % - session to select the anat from = opt.anatReference.session (default = 1)
  %
  % We assume that the first anat of that type is the "correct" one

  printBatchName('selecting anatomical image');

  [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt);

  matlabbatch{end + 1}.cfg_basicio.cfg_named_file.name = 'Anatomical';
  matlabbatch{end}.cfg_basicio.cfg_named_file.files = { {fullfile(anatDataDir, anatImage)} };

end
