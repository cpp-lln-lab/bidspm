function bidsResliceTpmToFunc(opt)
  %
  % Reslices the tissue probability map (TPMs) from the segmentation to the mean
  % functional and creates a mask for the bold mean image
  %
  % USAGE::
  %
  %   bidsResliceTpmToFunc(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Assumes that the anatomical has already been segmented by ``bidsSpatialPrepro()``
  % or ``bidsSegmentSkullStrip()``.
  %
  % It is necessary to run this workflow before running the ``functionalQA`` pipeline
  % as the computation of the tSNR by ``spmup`` requires the TPMs to have the same dimension
  % as the functional.
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  % TODO consider renaming this function to highlight that it creates a mask as
  % well, though this might get confusing with `bidsWholeBrainFuncMask`

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'reslicing tissue probability maps to functional dimension');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    opt.query.space = 'individual';
    [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt);

    % get grey and white matter and CSF tissue probability maps
    [gmTpm, wmTpm, csfTpm] = getTpms(BIDS, opt, subLabel);
    TPMs = cat(1, gmTpm, wmTpm, csfTpm);

    matlabbatch = {};
    matlabbatch = setBatchReslice(matlabbatch, ...
                                  opt, ...
                                  fullfile(meanFuncDir, meanImage), ...
                                  cellstr(TPMs));

    saveAndRunWorkflow(matlabbatch, 'reslice_tpm', opt, subLabel);

    %% Compute brain mask of functional
    prefix = spm_get_defaults('realign.write.prefix');
    input = cat(1,  spm_file(gmTpm, 'prefix', prefix), ...
                spm_file(wmTpm, 'prefix', prefix), ...
                spm_file(csfTpm, 'prefix', prefix));

    p = bids.internal.parse_filename(meanImage);
    p.entities.label = p.suffix;
    p.suffix = 'mask';

    bidsFile = bids.File(p);

    expression = sprintf('(i1+i2+i3)>%f', opt.skullstrip.threshold);

    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, ...
                                           input, bidsFile.filename, meanFuncDir, expression);

    saveAndRunWorkflow(matlabbatch, 'create_functional_brain_mask', opt, subLabel);

  end

  opt = set_spm_2_bids_defaults(opt);
  name_spec.entities.res = 'bold';
  opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', opt.spm_2_bids.realign, ...
                                              'name_spec', name_spec);
  opt.spm_2_bids = opt.spm_2_bids.flatten_mapping();

  bidsRename(opt);

end

function [gmTpm, wmTpm, csfTpm] = getTpms(BIDS, opt, subLabel)

  % TODO refactor with subfunction from setBatchNormalization

  gmTpm = '';
  wmTpm = '';
  csfTpm = '';

  anatFile = getAnatFilename(BIDS, opt, subLabel);

  if not(isempty(anatFile))

    anatFile = bids.internal.parse_filename(anatFile);

    filter = anatFile.entities;
    filter.modality = 'anat';
    filter.suffix = 'probseg';
    filter.space = 'individual';
    filter.desc =  '';
    filter.res =  '';
    filter.prefix = '';
    filter.extension = '.nii';

    filter.label = 'GM';
    gmTpm = bids.query(BIDS, 'data', filter);

    filter.label = 'WM';
    wmTpm = bids.query(BIDS, 'data', filter);

    filter.label = 'CSF';
    csfTpm = bids.query(BIDS, 'data', filter);

  end

  if any(isempty(cat(1, gmTpm, wmTpm, csfTpm)))
    msg = sprintf('Missing tissue probability map for subject %s', subLabel);
    errorHandling(mfilename(), 'missingTpms', msg, false);
  end
end
