function matlabbatch = setBatchSmoothConImages(matlabbatch, opt, funcFWHM, conFWHM)
  %
  % Creates a batch to smooth all the con images of all subjects
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSmoothConImages(matlabbatch, group, opt, funcFWHM, conFWHM)
  %
  % :param matlabbatch:
  % :type matlabbatch:
  % :param group:
  % :type group:
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt:
  % :param funcFWHM:
  % :type funcFWHM:
  % :param conFWHM:
  % :type conFWHM:
  %
  % :returns: - :matlabbatch:
  %
  % (C) Copyright 2019 CPP_SPM developers

  printBatchName('smoothing contrast images');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    ffxDir = getFFXdir(subLabel, funcFWHM, opt);

    conImg = spm_select('FPlist', ffxDir, '^con*.*nii$');
    data = cellstr(conImg);

    matlabbatch = setBatchSmoothing( ...
                                    matlabbatch, ...
                                    data, ...
                                    conFWHM, ...
                                    [spm_get_defaults('smooth.prefix'), num2str(conFWHM)]);

  end

end
