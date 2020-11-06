% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSmoothConImages(group, funcFWHM, conFWHM, opt)

  printBatchName('smoothing contrast images');

  counter = 0;

  matlabbatch = {};

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

      counter = counter + 1;

      subNumber = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subNumber);

      ffxDir = getFFXdir(subNumber, funcFWHM, opt);

      conImg = spm_select('FPlist', ffxDir, '^con*.*nii$');
      matlabbatch{counter}.spm.spatial.smooth.data = cellstr(conImg); %#ok<*AGROW>

      % Define how much smoothing is required
      matlabbatch{counter}.spm.spatial.smooth.fwhm = ...
          [conFWHM conFWHM conFWHM];
      matlabbatch{counter}.spm.spatial.smooth.dtype = 0;
      matlabbatch{counter}.spm.spatial.smooth.prefix = [ ...
                                                        spm_get_defaults('smooth.prefix'), ...
                                                        num2str(conFWHM)];

    end
  end

end
