% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

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
  % Lesion abnormalities detection will be performed using the information provided from the LesionSegmentation output in Bids format.
  %

  [BIDS, opt] = setUpWorkflow(opt, 'abnormalities detection');
  
%   participants = spm_load(fullfile(BIDS.dir, 'participants.tsv'));

controlSegmentedImages = [];
patientSegmentedImages = [];

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};
    
    [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);
    
    prefix = ('rc[12]');
    
    files = validationInputFile(anatDataDir, anatImage, prefix);
    
    idx = strcmp(BIDS.participants.participant_id, ['sub-' subLabel]);
    
    temp = BIDS.participants.group(idx);
    
    if strcmp (temp, 'control')
        controlSegmentedImages{end + 1, 1} = files;
    else
        patientSegmentedImages{end + 1, 1} = files; 
    end
   
        
    printProcessingSubject(iSub, subLabel);

  end

    matlabbatch = [];
    matlabbatch = setBatchLesionAbnormalitiesDetection(matlabbatch, controlSegmentedImages, patientSegmentedImages);

    saveAndRunWorkflow(matlabbatch, 'LesionAbnormalitiesDetection', opt, subLabel);

%     copyFigures(BIDS, opt, subLabel);

end
