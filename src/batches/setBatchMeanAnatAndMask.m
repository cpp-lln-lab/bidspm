% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchMeanAnatAndMask(opt, funcFWHM, rfxDir)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: Options chosen for the analysis. See ``checkOptions()``.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %

  [group, opt, BIDS] = getData(opt);

  matlabbatch = {};

  printBatchName('create mean anatomical image and mask');

  subCounter = 0;

  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

      subCounter = subCounter + 1;

      subID = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subID);

      %% STRUCTURAL
      [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt);

      anatImage = validationInputFile( ...
                                      anatDataDir, ...
                                      anatImage, ...
                                      [spm_get_defaults('normalise.write.prefix'), ...
                                       spm_get_defaults('deformations.modulate.prefix')]);

      matlabbatch{1}.spm.util.imcalc.input{subCounter, :} = anatImage;

      %% Mask
      ffxDir = getFFXdir(subID, funcFWHM, opt);

      files = validationInputFile(ffxDir, 'mask.nii');

      matlabbatch{2}.spm.util.imcalc.input{subCounter, :} = files;

    end
  end

  %% Generate the equation to get the mean of the mask and structural image
  % example : if we have 5 subjects, Average equation = '(i1+i2+i3+i4+i5)/5'
  nbImg = subCounter;
  imgRange  = 1:subCounter;

  tmpImg = sprintf('+i%i', imgRange);
  tmpImg = tmpImg(2:end);
  sumEquation = ['(', tmpImg, ')'];

  % meanStruct_equation = '(i1+i2+i3+i4+i5)/5'
  meanStruct_equation = ['(', tmpImg, ')/', num2str(nbImg)];

  % ------
  % TODO
  % not sure this makes sense for the mask as voxels that have no data for one
  % subject are excluded anyway !!!!

  % meanMask_equation = '(i1+i2+i3+i4+i5)>0.75*5'
  meanMask_equation = strcat(sumEquation, '>0.75*', num2str(nbImg));

  %% The mean structural will be saved in the RFX folder
  matlabbatch{1}.spm.util.imcalc.output = 'meanAnat.nii';
  matlabbatch{1}.spm.util.imcalc.outdir{:} = rfxDir;
  matlabbatch{1}.spm.util.imcalc.expression = meanStruct_equation;

  %% The mean mask will be saved in the RFX folder
  matlabbatch{2}.spm.util.imcalc.output = 'meanMask.nii';
  matlabbatch{2}.spm.util.imcalc.outdir{:} = rfxDir;
  matlabbatch{2}.spm.util.imcalc.expression = meanMask_equation;

end
