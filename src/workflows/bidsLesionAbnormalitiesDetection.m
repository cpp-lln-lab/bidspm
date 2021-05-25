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

controlSegmentedImagesGM = [];
patientSegmentedImagesGM = [];

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};
    
    [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);
    
%     prefix = ('rc[12]'); runs both at the same time

    prefix = 'rc1'; %tissue class 1: grey matter
    files = validationInputFile(anatDataDir, anatImage, prefix);
    
    idx = strcmp(BIDS.participants.participant_id, ['sub-' subLabel]);
    
    temp = BIDS.participants.group(idx);
    
    if strcmp (temp, 'control')
        controlSegmentedImagesGM{end + 1, 1} = files;
    else
        patientSegmentedImagesGM{end + 1, 1} = files; 
    end
   
        
    printProcessingSubject(iSub, subLabel);

  end

  
controlSegmentedImagesWM = [];
patientSegmentedImagesWM = [];

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};
    
    [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);
    
    prefixWM = 'rc2'; %tissue class 1: white matter WM
    files = validationInputFile(anatDataDir, anatImage, prefixWM);
    
    idx = strcmp(BIDS.participants.participant_id, ['sub-' subLabel]);
    
    temp = BIDS.participants.group(idx);
    
    if strcmp (temp, 'control')
        controlSegmentedImagesWM{end + 1, 1} = files;
    else
        patientSegmentedImagesWM{end + 1, 1} = files; 
    end
   
        
    printProcessingSubject(iSub, subLabel);

  end
  
    matlabbatch = [];
    matlabbatch = setBatchLesionAbnormalitiesDetection(matlabbatch, controlSegmentedImagesGM, patientSegmentedImagesGM, controlSegmentedImagesWM, patientSegmentedImagesWM);

    saveAndRunWorkflow(matlabbatch, 'LesionAbnormalitiesDetection', opt, subLabel);

%     copyFigures(BIDS, opt, subLabel);

end
