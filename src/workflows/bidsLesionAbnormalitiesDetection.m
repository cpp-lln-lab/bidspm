function bidsLesionAbnormalitiesDetection(opt)
  %
  % Use the ALI toolbox to detect lesion abnormalities in anatomical image
  % after segmentation of the image.
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
  %
  % (C) Copyright 2021 CPP_SPM developers

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'abnormalities detection');

  labels = {'GM', 'WM'};

  % create a structure to collect image names
  for i = 1:numel(labels)
    images(i, 1) = struct('controls', [], 'patients', []);
  end

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    idx = strcmp(BIDS.participants.content.participant_id, ['sub-' subLabel]);
    participantsGroup = BIDS.participants.content.group(idx);

    anatImage = getAnatFilename(BIDS, opt, subLabel);
    anatImage = bids.internal.parse_filename(anatImage);
    filter = anatImage.entities;
    filter.modality = 'anat';
    filter.suffix = 'probseg';
    filter.desc = 'smth8';

    for i = 1:numel(labels)

      filter.label = labels{i};
      files = bids.query(BIDS, 'data', filter);

      if numel(files) > 1
        disp(files);
        tolerant =  false;
        msg = sprintf('Too many files for label %s for subject %s', labels{i}, subLabel);
        id = 'tooManyTissueClassFiles';
        errorHandling(mfilename(), id, msg, tolerant);
      end

      % TODO avoid the hard coding of 'control' :
      % this should probably be in the opt
      if strcmp (participantsGroup, 'control')
        images(i, 1).controls{end + 1, 1} = files{1};
      else
        images(i, 1).patients{end + 1, 1} = files{1};
      end

    end

  end

  matlabbatch = {};
  matlabbatch = setBatchLesionAbnormalitiesDetection(matlabbatch, opt, images);

  saveAndRunWorkflow(matlabbatch, 'LesionAbnormalitiesDetection', opt, subLabel);

end
