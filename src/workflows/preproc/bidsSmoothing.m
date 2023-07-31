function bidsSmoothing(opt)
  %
  % This performs smoothing to the functional data using a full width
  % half maximum smoothing kernel of size "opt.fwhm.func".
  %
  % USAGE::
  %
  %   bidsSmoothing(opt)
  %
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  % :type opt: structure
  %
  %

  % (C) Copyright 2020 bidspm developers

  opt.dir.input = opt.dir.preproc;

  modality = 'func';
  if ~isempty(opt.query.modality)
    modality = opt.query.modality;
  end
  opt.query.modality = modality;

  clear modality;

  opt.query.space = opt.space;

  [BIDS, opt] = setUpWorkflow(opt, 'smoothing data');

  allRT = {};
  unRenamedFiles = {};

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    for i = 1:numel(opt.query.modality)

      modality  = opt.query.modality{i};

      switch modality
        case 'func'
          matlabbatch = {};
          [matlabbatch, allRT{iSub}] = setBatchSmoothingFunc(matlabbatch, ...
                                                             BIDS, ...
                                                             opt, ...
                                                             subLabel); %#ok<AGROW>
          [~, unRenamedFiles{iSub}] = saveAndRunWorkflow(matlabbatch, ...
                                                         ['smoothing_FWHM-', ...
                                                          num2str(opt.fwhm.func)], ...
                                                         opt, ...
                                                         subLabel);
        case 'anat'
          % TODO opt.fwhm.func should also have a opt.fwhm.anat
          matlabbatch = {};
          matlabbatch = setBatchSmoothingAnat(matlabbatch, BIDS, opt, subLabel);
          saveAndRunWorkflow(matlabbatch, ['smoothing_FWHM-' num2str(opt.fwhm.func)], ...
                             opt, ...
                             subLabel);
        otherwise
          notImplemented(mfilename(), ...
                         sprintf('smoothing for modality %s not implemented', modality));
      end

    end

  end

  cleanUpWorkflow(opt);

  prefix = get_spm_prefix_list;
  opt.query.prefix = [prefix.smooth, num2str(opt.fwhm.func)];
  opt.query.space = opt.space;
  createdFiles = bidsRename(opt);

  % add Repetition Time to smoothed files metadata
  for iSub = 1:numel(opt.subjects)
    subLabel = opt.subjects{iSub};
    for iFile = 1:numel(createdFiles)
      bf = bids.File(createdFiles{iFile});
      if ~strcmp(bf.suffix, 'bold') || ~strcmp(bf.entities.sub, subLabel)
        continue
      end
      jsonFile = spm_file(createdFiles{iFile}, 'ext', '.json');
      if exist(jsonFile, 'file')
        metadata = bids.util.jsondecode(jsonFile);
        idx = ismember(metadata.SpmFilename, ...
                       spm_file(unRenamedFiles{iSub}{1}.files, 'filename'));
        rt = allRT{iSub}(idx);
        metadata.RepetitionTime = rt;
        bids.util.jsonencode(jsonFile, metadata);
      end
    end
  end

end
