function bidsCreateROI(opt)
  %
  % Use CPP_ROI and marsbar to create a ROI in MNI space based on a given atlas
  % and inverse normalize those ROIs in native space if requested.
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % USAGE::
  %
  %  opt = get_option();
  %  opt.roi.atlas = 'wang';
  %  opt.roi.name = {'V1v', 'V1d'};
  %  opt.roi.space = {'IXI549Space', 'individual'};
  %  opt.dir.stats = fullfile(opt.dir.raw, '..', 'derivatives', 'cpp_spm-stats');
  %
  %  bidsCreateROI(opt);
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  if nargin < 1
    opt = [];
  end

  if ~isfield(opt.dir, 'roi')
    opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'cpp_spm-roi'), 'cpath');
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

      %% inverse normalize
      deformation_field = bids.query(BIDS, 'data', ...
                                     'sub', subLabel, 'suffix', 'xfm', ...
                                     'to', opt.bidsFilterFile.t1w.suffix, 'extension', '.nii');

      if isempty(deformation_field)
        tolerant = true;
        msg = sprintf('No deformation field for subject %s', subLabel);
        id = 'noDeformationField';
        errorHandling(mfilename(), id, msg, tolerant, opt.verbosity);
        continue
      end

      matlabbatch = {};
      for iROI = 1:size(roiList, 1)
        matlabbatch = setBatchNormalize(matlabbatch, ...
                                        deformation_field, ...
                                        nan(1, 3), ...
                                        roiList(iROI, :));
        matlabbatch{end}.spm.spatial.normalise.write.woptions.bb = nan(2, 3);
      end

      saveAndRunWorkflow(matlabbatch, 'inverseNormalize', opt, subLabel);

      %% move and rename file
      spm_mkdir(opt.dir.roi, ['sub-' subLabel], 'roi');

      roiList = spm_select('FPlist', ...
                           fullfile(opt.dir.roi, 'group'), ...
                           '^w.*space.*_mask.nii.*$');
      roiList = cellstr(roiList);

      if noRoiFound(opt, roiList, 'folder', fullfile(opt.dir.roi, 'group'))
        continue
      end

      if opt.dryRun
        tolerant = true;
        msg = 'Renaming ROI in native space will not work on a dry run';
        id = 'willNotRunOnDryRun';
        errorHandling(mfilename(), id, msg, tolerant, opt.verbosity);
        continue
      end

      for iROI = 1:size(roiList, 1)

        bidsFile = bids.File(outputNameStructure(subLabel, roiList{iROI, 1}));

        movefile(roiList{iROI, 1}, ...
                 fullfile(opt.dir.roi, ['sub-' subLabel], 'roi', bidsFile.filename));

      end

    end

  end

  opt.dir.output = opt.dir.roi;
  opt.pipeine.type = 'roi';
  initBids(opt, 'description', 'group and subject ROIs');

  cleanUpWorkflow(opt);

end

function nameStructure = outputNameStructure(subLabel, roiFilename)

  p = bids.internal.parse_filename(roiFilename);
  if isfield(p.entities, 'whemi')
    p.entities = renameStructField(p.entities, 'whemi', 'hemi');
  end
  fields = {'hemi', 'desc', 'label'};
  for iField = 1:numel(fields)
    if ~isfield(p.entities, fields{iField})
      p.entities.(fields{iField}) = '';
    end
  end
  nameStructure = struct('entities', struct( ...
                                            'sub', subLabel, ...
                                            'space', 'individual', ...
                                            'hemi', p.entities.hemi, ...
                                            'label', p.entities.label, ...
                                            'desc', p.entities.desc), ...
                         'suffix', 'mask', ...
                         'ext', '.nii');

end
