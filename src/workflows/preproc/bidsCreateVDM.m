function bidsCreateVDM(opt)
  %
  % Creates the voxel displacement maps from the fieldmaps of a BIDS
  % dataset.
  %
  % USAGE::
  %
  %   bidsCreateVDM(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % .. TODO:
  %
  %    - take care of all types of fieldmaps
  %
  % Inspired from spmup ``spmup_BIDS_preprocess`` (@ commit 198c980d6d7520b1a99)
  % (URL missing)
  %
  % (C) Copyright 2020 CPP_SPM developers

  opt.pipeline.type = 'preproc';

  [BIDS, opt] = setUpWorkflow(opt, 'create voxel displacement map');

  opt.rename = false;

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    % TODO Move to getInfo
    suffixes = bids.query(BIDS, 'suffixes', 'sub', subLabel);

    if any(ismember(suffixes, {'phase12', 'phasediff', 'fieldmap', 'epi'}))

      opt.rename = true;

      printProcessingSubject(iSub, subLabel, opt);

      % Create rough mean of the 1rst run to improve SNR for coregistration
      % TODO use the slice timed EPI if STC was used ?
      sessions = getInfo(BIDS, subLabel, opt, 'Sessions');
      runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{1});
      [fileName, subFuncDataDir] = getBoldFilename(BIDS, subLabel, sessions{1}, runs{1}, opt);
      spmup_basics(fullfile(subFuncDataDir, fileName), 'mean');

      matlabbatch = {};
      matlabbatch = setBatchCoregistrationFmap(matlabbatch, BIDS, opt, subLabel);
      saveAndRunWorkflow(matlabbatch, 'coregister_fmap', opt, subLabel);

      matlabbatch = {};
      matlabbatch = setBatchCreateVDMs(matlabbatch, BIDS, opt, subLabel);
      saveAndRunWorkflow(matlabbatch, 'create_vdm', opt, subLabel);

      % TODO delete temporary mean images ??

    end

  end

  bidsRename(opt);

end
