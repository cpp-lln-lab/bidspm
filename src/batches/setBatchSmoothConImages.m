% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSmoothConImages(matlabbatch, group, opt, funcFWHM, conFWHM)
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

  printBatchName('smoothing contrast images');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

      subNumber = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subNumber);

      ffxDir = getFFXdir(subNumber, funcFWHM, opt);

      conImg = spm_select('FPlist', ffxDir, '^con*.*nii$');
      data = cellstr(conImg);

      matlabbatch = setBatchSmoothing( ...
                                      matlabbatch, ...
                                      data, ...
                                      conFWHM, ...
                                      [spm_get_defaults('smooth.prefix'), num2str(conFWHM)]);

    end

  end

end
