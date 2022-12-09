function bidsCreateROI(opt)
  %
  % Use CPP_ROI and marsbar to create a ROI in MNI space based on a given atlas
  % and inverse normalize those ROIs in native space if requested.
  %
  % :type  opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  %
  % USAGE::
  %
  %  opt = get_option();
  %  opt.roi.atlas = 'wang';
  %  opt.roi.name = {'V1v', 'V1d'};
  %  opt.roi.space = {'IXI549Space', 'individual'};
  %  opt.dir.stats = fullfile(opt.dir.raw, '..', 'derivatives', 'bidspm-stats');
  %
  %  bidsCreateROI(opt);
  %
  %

  % (C) Copyright 2021 bidspm developers

  if nargin < 1
    opt = [];
  end

  if ~isfield(opt.dir, 'roi')
    opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'bidspm-roi'), 'cpath');
  end
  spm_mkdir(fullfile(opt.dir.roi, 'group'));

  hemi = {'L', 'R'};

  for iHemi = 1:numel(hemi)

    for iROI = 1:numel(opt.roi.name)

      extractRoiFromAtlas(fullfile(opt.dir.roi, 'group'), ...
                          opt.roi.atlas, ...
                          opt.roi.name{iROI}, ...
                          hemi{iHemi});

    end

  end

  if any(strcmp(opt.roi.space, 'individual'))

    roiList = spm_select('FPlist', ...
                         fullfile(opt.dir.roi, 'group'), ...
                         '^[^w].*_mask.nii$');
    roiList = cellstr(roiList);
    if noRoiFound(opt, roiList, 'folder', fullfile(opt.dir.roi, 'group'))
      return
    end

    opt.dir.jobs = fullfile(opt.dir.roi, 'jobs');
    opt.dir.input = opt.dir.preproc;

    [BIDS, opt] = setUpWorkflow(opt, 'create ROI');

    for iSub = 1:numel(opt.subjects)

      subLabel = opt.subjects{iSub};

      printProcessingSubject(iSub, subLabel, opt);

      matlabbatch = {};
      matlabbatch = setBatchInverseNormalize(matlabbatch, BIDS, opt, subLabel, roiList);

      deformationField = matlabbatch{1}.spm.spatial.normalise.write.subj.def{1};

      saveAndRunWorkflow(matlabbatch, 'inverseNormalize', opt, subLabel);

      %% move and rename file
      roiList = spm_select('FPlist', ...
                           fullfile(opt.dir.roi, 'group'), ...
                           '^w.*space.*_mask.nii.*$');
      roiList = cellstr(roiList);

      if noRoiFound(opt, roiList, 'folder', fullfile(opt.dir.roi, 'group'))
        continue
      end

      if opt.dryRun
        msg = 'Renaming ROI in native space will not work on a dry run';
        id = 'willNotRunOnDryRun';
        logger('WARNING', msg, ...
               'options', opt, ...
               'id', id, ...
               'filename', mfilename());
        continue
      end

      for iROI = 1:size(roiList, 1)

        roiBidsFile = buildIndividualSpaceRoiFilename(deformationField, roiList{iROI, 1});

        spm_mkdir(fullfile(opt.dir.roi, roiBidsFile.bids_path, 'roi'));

        movefile(roiList{iROI, 1}, ...
                 fullfile(opt.dir.roi, roiBidsFile.bids_path, 'roi', roiBidsFile.filename));

      end

    end

  end

  opt.dir.output = opt.dir.roi;
  opt.pipeline.type = 'roi';
  initBids(opt, 'description', 'group and subject ROIs');

  cleanUpWorkflow(opt);

end
