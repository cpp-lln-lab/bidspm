% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSmoothConImages(matlabbatch, group, funcFWHM, conFWHM, opt)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSmoothConImages(group, funcFWHM, conFWHM, opt)
  %
  % :param group:
  % :type group:
  % :param funcFWHM:
  % :type funcFWHM:
  % :param conFWHM:
  % :type conFWHM:
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt:
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
      matlabbatch{end + 1}.spm.spatial.smooth.data = cellstr(conImg); %#ok<*AGROW>

      % Define how much smoothing is required
      matlabbatch{end}.spm.spatial.smooth.fwhm = [conFWHM conFWHM conFWHM];
      matlabbatch{end}.spm.spatial.smooth.dtype = 0;
      matlabbatch{end}.spm.spatial.smooth.prefix = [ ...
                                                    spm_get_defaults('smooth.prefix'), ...
                                                    num2str(conFWHM)];

    end

  end

end
