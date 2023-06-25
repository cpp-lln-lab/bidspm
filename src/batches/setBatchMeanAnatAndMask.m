function matlabbatch = setBatchMeanAnatAndMask(matlabbatch, opt, outputDir)
  %
  % Creates batxh to create mean anatomical image and a group mask
  %
  % USAGE::
  %
  %   matlabbatch = setBatchMeanAnatAndMask(matlabbatch, opt, funcFWHM, outputDir)
  %
  % :param matlabbatch:
  % :type  matlabbatch: structure
  %
  % :type  opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  %
  % :param outputDir:
  % :type  outputDir: string
  %
  % :returns: - :matlabbatch: (structure)
  %

  % (C) Copyright 2019 bidspm developers

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  printBatchName('create mean anatomical image and mask', opt);

  %% Collect images
  inputAnat = {};
  inputMask = {};

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    %% Anat
    opt.bidsFilterFile.t1w.space = opt.space;
    opt.bidsFilterFile.t1w.desc = 'preproc';

    [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

    inputAnat{end + 1, 1} = fullfile(anatDataDir, anatImage); %#ok<*AGROW>

    %% Mask
    filter = struct('ext', '.nii', ...
                    'modality', 'anat', ...
                    'suffix', 'mask', ...
                    'sub', subLabel, ...
                    'space', opt.space);

    files = bids.query(BIDS, 'data', filter);

    assert(numel(files) == 1);
    inputMask{end + 1, 1} = files{1};

  end

  %% The mean structural will be saved in the group level folder
  opt.orderBatches.mean = 1;

  spec = struct('suffix', opt.bidsFilterFile.t1w.suffix,  ...
                'ext', '.nii', ...
                'entities', struct('space', opt.bidsFilterFile.t1w.space, ...
                                   'desc', 'mean'));
  if iscell(spec.entities.space)
    spec.entities.space = spec.entities.space{1};
  end
  meanAnat = bids.File(spec);

  matlabbatch = setBatchImageCalculation(matlabbatch, ...
                                         opt, ...
                                         inputAnat, ...
                                         meanAnat.filename, ...
                                         outputDir, ...
                                         meanImageEquation(inputAnat));

  %% The mean mask will be saved in the group level folder
  opt.orderBatches.mask = 2;

  spec = struct('suffix', 'mask',  ...
                'ext', '.nii', ...
                'entities', struct('space', opt.bidsFilterFile.t1w.space, ...
                                   'desc', 'brain'));
  if iscell(spec.entities.space)
    spec.entities.space = spec.entities.space{1};
  end
  mask = bids.File(spec);

  matlabbatch = setBatchImageCalculation(matlabbatch, ...
                                         opt, ...
                                         inputMask, ...
                                         mask.filename, ...
                                         outputDir, ...
                                         allMaskEquation(inputMask));

  %% smooth anat
  % once like the functional
  % a second time like the contrasts
  prefix = get_spm_prefix_list;

  if opt.fwhm.func > 0

    opt.orderBatches.smooth = 3;

    images = cfg_dep('Image Calculator: mean T1w', ...
                     returnDependency(opt, 'mean'), ...
                     substruct('.', 'files'));
    matlabbatch = setBatchSmoothing(matlabbatch, opt, ...
                                    images, ...
                                    opt.fwhm.func, ...
                                    [prefix.smooth, num2str(opt.fwhm.func)]);
    matlabbatch{end}.spm.spatial.smooth.im = 1;
  end

  if opt.fwhm.contrast > 0

    images = cfg_dep('Smooth: Smoothed mean T1w', ...
                     returnDependency(opt, 'smooth'), ...
                     substruct('.', 'files'));
    matlabbatch = setBatchSmoothing(matlabbatch, opt, ...
                                    images, ...
                                    opt.fwhm.func, ...
                                    [prefix.smooth, num2str(opt.fwhm.contrast)]);
    matlabbatch{end}.spm.spatial.smooth.im = 1;

    opt.orderBatches.smooth = 4;

  end

  %% mask anat (that was eventually smoothed)
  opt.orderBatches.maskedMean = numel(matlabbatch) + 1;

  meanAnat.entities.desc = 'maskedMean';

  input(1) = cfg_dep('Image Calculator: mask.nii', ...
                     returnDependency(opt, 'mask'), ...
                     substruct('.', 'files'));

  if isfield(opt.orderBatches, 'smooth')
    input(2) = cfg_dep('Smooth: Smoothed mean T1w', ...
                       returnDependency(opt, 'smooth'), ...
                       substruct('.', 'files'));
  else
    input(2) = cfg_dep('Image Calculator: mean T1w', ...
                       returnDependency(opt, 'mean'), ...
                       substruct('.', 'files'));
  end

  matlabbatch = setBatchImageCalculation(matlabbatch, ...
                                         opt, ...
                                         input, ...
                                         meanAnat.filename, ...
                                         outputDir, ...
                                         'i1.*i2');

  %% rename smoothed image
  opt.orderBatches.rename = numel(matlabbatch) + 1;

  files = cfg_dep('Image Calculator: masked mean T1w', ...
                  returnDependency(opt, 'maskedMean'), ...
                  substruct('.', 'files'));

  matlabbatch{end + 1}.cfg_basicio.file_dir.file_ops.file_move.files = files;

  moveren.moveto = {outputDir};
  moveren.patrep(1).pattern = '^s[0-9].*space-';
  moveren.patrep(1).repl = 'space-';
  moveren.patrep(2).pattern = '_desc-.*.nii$';
  moveren.patrep(2).repl = ['_desc-meanMasked_' ...
                            opt.bidsFilterFile.t1w.suffix, ...
                            '.nii'];
  moveren.unique = false;

  matlabbatch{end}.cfg_basicio.file_dir.file_ops.file_move.action.moveren = moveren;

  %% view images
  data(1) = cfg_dep('Image Calculator: mean T1w', ...
                    returnDependency(opt, 'mean'), ...
                    substruct('.', 'files'));
  data(2) = cfg_dep('Image Calculator: mask.nii', ...
                    returnDependency(opt, 'mask'), ...
                    substruct('.', 'files'));
  data(3) = cfg_dep('Smooth: Smoothed mean T1w', ...
                    returnDependency(opt, 'smooth'), ...
                    substruct('.', 'files'));
  data(4) = cfg_dep('Rename: Masked smoothed mean', ...
                    returnDependency(opt, 'rename'), ...
                    substruct('.', 'files'));

  matlabbatch{end + 1}.spm.util.checkreg.data = data;

end

function value = sumEquation(listImages)
  nbImg = numel(listImages);
  imgRange = 1:nbImg;

  tmpImg = sprintf('+i%i', imgRange);
  tmpImg = tmpImg(2:end);
  value = ['(', tmpImg, ')'];
end

function value = meanImageEquation(listImages)
  % meanImageEquation = '(i1+i2+i3+i4+i5)/5'
  nbImg = numel(listImages);
  value = [sumEquation(listImages), '/', num2str(nbImg)];
end

function value = allMaskEquation(listImages)
  % allMaskEquation = '(i1+i2+i3+i4+i5)==5'
  nbImg = numel(listImages);
  value = [sumEquation(listImages), '==1*', num2str(nbImg)];
end
