function matlabbatch = setBatchSmoothConImages(matlabbatch, opt)
  %
  % Creates a batch to smooth all the con images of all subjects
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSmoothConImages(matlabbatch, opt)
  %
  % :param matlabbatch:
  % :type  matlabbatch: structure
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  %
  % :returns: - :matlabbatch:
  %
  %
  % See also: bidsRFX, setBatchSmoothing, setBatchSmoothingFunc
  %

  % (C) Copyright 2019 bidspm developers

  [~, opt] = getData(opt, opt.dir.preproc);

  printBatchName('smoothing contrast images', opt);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    ffxDir = getFFXdir(subLabel, opt);

    conImg = spm_select('FPlist', ffxDir, '^con*.*nii$');
    data = cellstr(conImg);

    matlabbatch = setBatchSmoothing(matlabbatch, ...
                                    opt, ...
                                    data, ...
                                    opt.fwhm.contrast, ...
                                    [spm_get_defaults('smooth.prefix'), ...
                                     num2str(opt.fwhm.contrast)]);

  end

end
