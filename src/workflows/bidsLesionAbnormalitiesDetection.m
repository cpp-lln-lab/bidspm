function bidsLesionAbnormalitiesDetection(opt)
  %
  % Step 2. Detects lesion abnormalities in anatomical image after segmentation of the image.
  %
  % USAGE::
  %
  %  bidsLesionAbnormalitiesDetection(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Lesion abnormalities detection will be performed using the information provided
  % from the lesion segmentation output in BIDS format.
  %
  % (C) Copyright 2021 CPP_SPM developers

  [BIDS, opt] = setUpWorkflow(opt, 'abnormalities detection');

  prefixList = {'rc1', 'rc2'};

  % create a structure to collect image names
  for iPrefix = 1:numel(prefixList)
    images(iPrefix, 1) = struct('controls', [], 'patients', []);
  end

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    idx = strcmp(BIDS.participants.participant_id, ['sub-' subLabel]);

    temp = BIDS.participants.group(idx);

    [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

    for iPrefix = 1:numel(prefixList)

      prefix = prefixList{iPrefix};
      files = validationInputFile(anatDataDir, anatImage, prefix);

      if strcmp (temp, 'control')
        images(iPrefix, 1).controls{end + 1, 1} = files;
      else
        images(iPrefix, 1).patients{end + 1, 1} = files;
      end

    end
  end

  matlabbatch = {};
  matlabbatch = setBatchLesionAbnormalitiesDetection(matlabbatch, opt, images);

  saveAndRunWorkflow(matlabbatch, 'LesionAbnormalitiesDetection', opt, subLabel);

end
