function matlabbatch = setBatchMeanAnatAndMask(matlabbatch, opt, funcFWHM, outputDir)
  %
  % Creates batxh to create mean anatomical image and a group mask
  %
  % USAGE::
  %
  %   matlabbatch = setBatchMeanAnatAndMask(matlabbatch, opt, funcFWHM, outputDir)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param funcFWHM:
  % :param outputDir:
  % :type outputDir: tring
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2019 CPP_SPM developers

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  printBatchName('create mean anatomical image and mask', opt);

  inputAnat = {};
  inputMask = {};

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    %% Anat
    opt.query.space = 'MNI';
    opt.query.desc = 'preproc';
    [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

    inputAnat{end + 1, 1} = fullfile(anatDataDir, anatImage); %#ok<*AGROW>

    %% Mask
    ffxDir = getFFXdir(subLabel, funcFWHM, opt);

    files = validationInputFile(ffxDir, 'mask.nii');

    inputMask{end + 1, 1} = files;

  end

  %% Generate the equation to get the mean of the mask and structural image
  % example : if we have 5 subjects, Average equation = '(i1+i2+i3+i4+i5)/5'
  nbImg = numel(inputAnat);
  imgRange = 1:nbImg;

  tmpImg = sprintf('+i%i', imgRange);
  tmpImg = tmpImg(2:end);
  sumEquation = ['(', tmpImg, ')'];

  %% The mean structural will be saved in the group level folder
  % meanStructEquation = '(i1+i2+i3+i4+i5)/5'
  meanAnatEquation = [sumEquation, '/', num2str(nbImg)];

  matlabbatch = setBatchImageCalculation(matlabbatch, ...
                                         opt, ...
                                         inputAnat, ...
                                         'meanAnat.nii', ...
                                         outputDir, ...
                                         meanAnatEquation);

  %% The mean mask will be saved in the group level folder

  % TODO
  % not sure this makes sense for the mask as voxels that have no data for one
  % subject are excluded anyway !!!!

  % meanMaskEquation = '(i1+i2+i3+i4+i5)>0.75*5'
  meanMaskEquation = [sumEquation, '>0.75*', num2str(nbImg)];

  matlabbatch = setBatchImageCalculation(matlabbatch, ...
                                         opt, ...
                                         inputMask, ...
                                         'meanMask.nii', ...
                                         outputDir, ...
                                         meanMaskEquation);

end
