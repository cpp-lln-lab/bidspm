% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSmoothConImages(group, funcFWHM, conFWHM, opt)
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
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  
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
