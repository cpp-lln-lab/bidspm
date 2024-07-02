function opt = checkOptions(opt)
  %
  % Check the option inputs and add any missing field with some defaults
  %
  % USAGE::
  %
  %   opt = checkOptions(opt)
  %
  % :param opt: Options chosen for the analysis.
  % :type  opt: structure
  %
  % :return: opt
  % :rtype: structure
  %
  %
  % **GENERIC OPTIONS**
  %
  % - ``opt.dir`` - See :func:`setDirectories`.
  %
  % - ``opt.groups = {''}`` -
  %   Group of subjects to analyze
  %
  % - ``opt.subjects = {[]}`` -
  %   Suject to run in each group.
  %
  % - ``opt.space = {'individual', 'IXI549Space'}`` -
  %   Space where we conduct the analysis
  %
  % - ``opt.taskName``
  %
  % - ``opt.query = struct('modality', {{'anat', 'func'}})`` -
  %   a structure used to specify subset of files to only run analysis on.
  %   See :func:`bids.query` to see how to specify.
  %
  %   .. warning::
  %
  %     ``opt.query`` might be progressively deprecated in favor of ``opt.bidsFilterFile``
  %     that allows using different filters for T1w and bold data.
  %
  % - ``opt.bidsFilterFile`` -
  %   Sets how to define a typical images "bold", "T1w"... in terms of their bids entities.
  %   The default value is:
  %
  %   .. code-block:: matlab
  %
  %      struct('fmap', struct('modality', 'fmap'), ...
  %             'bold', struct('modality', 'func', 'suffix', 'bold'), ...
  %             't2w',  struct('modality', 'anat', 'suffix', 'T2w'), ...
  %             't1w',  struct('modality', 'anat', 'space', '', 'suffix', 'T1w'), ...
  %             'roi',  struct('modality', 'roi', 'suffix', 'mask'), ...
  %             'xfm',  struct('modality', 'anat', 'suffix', 'xfm', 'to', 'T1w'));
  %
  % - ``opt.verbosity = 1`` - Set it to ``0``
  %   if you want to see less output on the prompt.
  %
  % - ``opt.tolerant = true`` -
  %   Set it to ``false`` if you want turn warning into errors.
  %
  % - ``opt.dryRun = false`` -
  %   Set it to ``true`` in case you don't want to run the analysis.
  %
  % - ``opt.pipeline.type = 'preproc'`` -
  %   Switch it to ``stats`` when running GLMs.
  % - ``opt.pipeline.name``
  % - ``opt.pipeline.isBms`` whether this is a bayesion model selection
  %   pipeline
  %
  % - ``opt.boilerplateOnly = false`` -
  %   If set to ``true`` only creates dataset description reports and methods description.
  %   Overwrites previous versions.
  %
  % - ``opt.zeropad = 2`` -
  %   Number of zeros used for padding subject numbers,
  %   in case subjects should be fetched by their index ``1``
  %   and not their label ``O1'``.
  %
  % - ``opt.rename.do = true`` -
  %   Set to ``false`` to skip renaming files with :func:`bidsRename`.
  %   Mostly for debugging as the output files won't be usable
  %   by any of the stats workflows.
  % - ``opt.rename.overwrite = true`` -
  %   To overwrite any eventual previous output of :func:`bidsRename`.
  %
  % - ``opt.msg.color = blue`` -
  %   Default font color of the prompt messages.
  %
  % **PREPROCESSING OPTIONS**
  %
  % - ``opt.realign.useUnwarp = true``
  %
  % - ``opt.useFieldmaps = true`` -
  %   When set to ``true`` the preprocessing pipeline will look
  %   for the voxel displacement maps (created by :func:`bidsCreateVDM`)
  %   and will use them for realign and unwarp.
  %
  % - ``opt.fwhm.func = 6`` -
  %   FWHM to apply to the preprocessed functional images.
  %
  % - ``opt.anatOnly = false`` -
  %   Set to ``true`` to only preprocess the anatomical file.
  %
  % - ``opt.segment.force = false`` -
  %   Set to ``true`` to ignore previous output of the segmentation
  %   and force to run it again
  %
  % - ``opt.skullstrip.mean = false`` -
  %   Set to ``true`` to skulstrip mean functional image
  % - ``opt.skullstrip.threshold = 0.75`` -
  %   Threshold used for the skull stripping.
  %   Any voxel with
  %   ``p(grayMatter) +  p(whiteMatter) + p(CSF) > threshold``
  %   will be included in the mask.
  % - ``opt.skullstrip.do = true``  -
  %   Set to ``true`` to skip skullstripping.
  %
  % - ``opt.stc.skip = false`` -
  %   Boolean flag to skip slice time correction or not.
  % - ``opt.stc.referenceSlice = []`` -
  %   Reference slice (in seconds) for the slice timing correction.
  %   If left empty the mid-volume acquisition time point will be selected at run time.
  %
  % - ``opt.funcVoxelDims = []`` -
  %   Voxel dimensions to use for resampling of functional data at normalization.
  %
  %
  % **STATISTICS OPTIONS**
  %
  % - ``opt.model.file = ''`` -
  %   Path to the BIDS model file that contains the model
  %   to specify and the contrasts to compute.
  %   A path to a dir can be passed as well.
  %   In this case all ``*_smdl.json`` files will be used
  %   and looped over.
  %   This can useful to specify several models at once
  %   Before running Bayesion model selection on them.
  %
  % - ``opt.fwhm.contrast = 0`` -
  %   FWHM to apply to the contrast images before bringing them at the group level.
  %
  % - ``opt.model.designOnly =  false`` -
  %   If set to ``true``, the GLM will be specified without associating any data to it.
  %   Can be useful for quick design matrix inspection before running estimation.
  %
  % - ``opt.glm.roibased.do = false`` -
  %   Set to ``true`` to use the ``bidsRoiBasedGLM`` workflow.
  % - ``opt.glm.useDummyRegressor = false`` -
  %   Set to ``true`` to add dummy regressors when a condition is missing from a run.
  %   See :func:`bidsModelSelection` for more information.
  % - ``opt.glm.maxNbVols = Inf`` -
  %   Sets the maximum number of volumes to include in a run in a subject level GLM.
  %   This can be useful if some time series have more volumes than necessary.
  % - ``opt.glm.keepResiduals = false`` -
  %   Keep the subject level GLM residuals if set to ``true``.
  % - ``opt.glm.concatenateRuns = false`` -
  %   Concatenate "vertically" the images and and onsets of several run
  %   when set to true.
  %   Necessary to run a psycho-physiologial interaction analysis.
  %
  % - ``opt.QA.glm.do = false`` -
  %   If set to ``true`` the residual images of a GLM at the subject levels
  %   will be used to estimate if there is any remaining structure
  %   in the GLM residuals (the power spectra are not flat) that could indicate
  %   the subject level results are likely confounded.
  %   See ``plot_power_spectra_of_GLM_residuals.m`` and `Accurate autocorrelation modeling
  %   substantially improves fMRI reliability
  %   <https://www.nature.com/articles/s41467-019-09230-w.pdf>`_ for more info.
  %
  %

  % (C) Copyright 2019 bidspm developers

  fieldsToSet = setDefaultOption();
  opt = setFields(opt, fieldsToSet);

  %  Options for toolboxes
  opt = setFields(opt, MACS_my_defaults());

  checkFields(opt);

  if any(strcmp(opt.pipeline.name, {'bidspm-stats', 'bidspm-preproc'}))
    opt.pipeline.name = 'bidspm';
  end

  % coerce query modality into a cell
  if ~iscell(opt.query.modality)
    Results = opt.query.modality;
    opt.query = rmfield(opt.query, 'modality');
    opt.query.modality{1} = Results;
  end

  if isfield(opt, 'taskName') && ~iscell(opt.taskName)
    opt.taskName = {opt.taskName};
  end

  % deal with space
  if ~strcmpi(opt.pipeline.type, 'stats')
    fieldsToSet = struct('space', {{'individual', 'IXI549Space'}});
    opt = setFields(opt, fieldsToSet);
  end
  if isfield(opt, 'space') && ~iscell(opt.space)
    opt.space = {opt.space};
  end
  opt = mniToIxi(opt);

  opt = getOptionsFromModel(opt);

  opt = orderfields(opt);

  opt = setDirectories(opt);

  opt = checkResultsOptions(opt);

end

function opt = checkResultsOptions(opt)

  % validate content of opt.results

  defaultResults = defaultResultsStructure();
  if ~isfield(opt, 'results')
    opt.results = defaultResults;
    return
  end

  if isempty(opt.results)
    return
  end

  for iCon = 1:numel(opt.results)

    thisResult = opt.results(iCon);

    thisResult = fillInResultStructure(thisResult);

    results(iCon) = thisResult;

  end

  opt.results = results;

end

function fieldsToSet = setDefaultOption()

  % this defines the missing fields

  fieldsToSet.verbosity = 2;
  fieldsToSet.tolerant = true;
  fieldsToSet.dryRun = false;

  %% defines what counts as BOLD, T1W...
  fieldsToSet.bidsFilterFile = struct('fmap', struct('modality', 'fmap'), ...
                                      'bold', struct('modality', 'func', ...
                                                     'suffix', 'bold'), ...
                                      't2w',  struct('modality', 'anat', 'suffix', 'T2w'), ...
                                      't1w',  struct('modality', 'anat', ...
                                                     'space', '', ...
                                                     'suffix', 'T1w'), ...
                                      'mp2rage',  struct('modality', 'anat', ...
                                                         'space', '', ...
                                                         'suffix', 'MP2RAGE'), ...
                                      'roi',  struct('modality', 'roi', 'suffix', 'mask'), ...
                                      'xfm',  struct('modality', 'anat', ...
                                                     'suffix', 'xfm', ...
                                                     'to', 'T1w'));

  fieldsToSet.pipeline.type = '';
  fieldsToSet.pipeline.name = 'bidspm';
  fieldsToSet.pipeline.isBms = false;

  fieldsToSet.boilerplateOnly = false;

  fieldsToSet.useBidsSchema = false;

  fieldsToSet.dir = struct('input', '', ...
                           'output', '', ...
                           'derivatives', '', ...
                           'raw', '', ...
                           'preproc', '', ...
                           'stats', '', ...
                           'jobs', '');

  fieldsToSet.groups = {''};
  fieldsToSet.subjects = {[]};
  fieldsToSet.zeropad = 2;

  fieldsToSet.rename.do = true;
  fieldsToSet.rename.overwrite = true;

  fieldsToSet.query.modality = {'anat', 'func'};

  %% General options for anatomical data
  fieldsToSet.anatOnly = false;

  %% General options for functional data
  fieldsToSet.funcVolToSelect = [];

  fieldsToSet.dummyScans = 0;

  %% Options for slice time correction
  % all in seconds
  fieldsToSet.stc.referenceSlice = [];
  fieldsToSet.stc.skip = false;

  %% Options for realign
  fieldsToSet.realign.useUnwarp = true;
  fieldsToSet.useFieldmaps = true;

  %% Options for segmentation
  fieldsToSet.segment.do = true;
  fieldsToSet.segment.force = false;
  fieldsToSet.segment.biasfwhm = 60;
  fieldsToSet.segment.samplingDistance = 3;

  %% Options for skullstripping
  fieldsToSet.skullstrip.do = true;
  fieldsToSet.skullstrip.force = false;
  fieldsToSet.skullstrip.threshold = 0.75;
  fieldsToSet.skullstrip.mean = false;

  %% Options for normalize
  fieldsToSet.funcVoxelDims = [];

  %% Options for smoothing
  fieldsToSet.fwhm.func = 6;
  fieldsToSet.fwhm.contrast = 0;

  %% Options for model specification and results
  fieldsToSet.model.file = '';
  fieldsToSet.model.designOnly = false;
  fieldsToSet.contrastList = {};

  fieldsToSet.glm.roibased.do = false;
  fieldsToSet.glm.maxNbVols = Inf;
  fieldsToSet.glm.useDummyRegressor = false;
  fieldsToSet.glm.keepResiduals = false;
  fieldsToSet.glm.concatenateRuns = false;

  %% Options for QA
  fieldsToSet.QA.glm.do = false;

  %% Options for interface
  fieldsToSet.msg.color = '';

end

function checkFields(opt)

  if isfield(opt, 'taskName') && ...
      isempty(opt.taskName) && ...
      ~strcmp(opt.pipeline.type, 'stats')

    msg = 'You may need to provide the name of the task to analyze.';
    id = 'noTask';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

  end

  if ~all(cellfun(@ischar, opt.groups))

    msg = 'All group names should be string.';
    id = 'groupNotString';
    logger('ERROR', msg, 'filename', mfilename(), 'id', id);

  end

  if ~isempty(opt.stc.referenceSlice) && length(opt.stc.referenceSlice) > 1

    msg = sprintf(['options.stc.referenceSlice should be a scalar.' ...
                   '\nCurrent value is: %d'], ...
                  opt.stc.referenceSlice);
    id = 'refSliceNotScalar';
    logger('ERROR', msg, 'filename', mfilename(), 'id', id);

  end

  if ~isempty (opt.funcVoxelDims) && length(opt.funcVoxelDims) ~= 3

    msg = sprintf(['opt.funcVoxelDims should be a vector of length 3. '...
                   '\nCurrent value is: %d'], ...
                  opt.funcVoxelDims);
    id = 'voxDim';
    logger('ERROR', msg, 'filename', mfilename(), 'id', id);

  end

  if isfield(opt.model, 'hrfDerivatives')

    msg = ('HRF derivatives should be set in the BIDS stats model file, not in the options.');
    id = 'voxDim';
    logger('ERROR', msg, 'filename', mfilename(), 'id', id, 'options', opt);

  end

end
