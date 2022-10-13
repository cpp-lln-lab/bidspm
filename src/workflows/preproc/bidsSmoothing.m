function bidsSmoothing(opt)
  %
  % This performs smoothing to the functional data using a full width
  % half maximum smoothing kernel of size "mm_smoothing".
  %
  % USAGE::
  %
  %   bidsSmoothing(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
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

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    for i = 1:numel(opt.query.modality)

      modality  = opt.query.modality{i};

      switch modality
        case 'func'
          matlabbatch = {};
          matlabbatch = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subLabel);
          saveAndRunWorkflow(matlabbatch, ['smoothing_FWHM-' num2str(opt.fwhm.func)], opt, subLabel);
        case 'anat'
          % TODO opt.fwhm.func should also have a opt.fwhm.anat
          matlabbatch = {};
          matlabbatch = setBatchSmoothingAnat(matlabbatch, BIDS, opt, subLabel);
          saveAndRunWorkflow(matlabbatch, ['smoothing_FWHM-' num2str(opt.fwhm.func)], opt, subLabel);
        otherwise
          notImplemented(mfilename(), ...
                         sprintf('smoothing for modality %s not implemented', modality), ...
                         true);
      end

    end

  end

  prefix = get_spm_prefix_list;
  opt.query.prefix = [prefix.smooth, num2str(opt.fwhm.func)];
  opt.query.space = opt.space;
  bidsRename(opt);

end
