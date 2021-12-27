function opt = checkOptions(opt)
  %
  % Check the option inputs and add any missing field with some defaults
  %
  % USAGE::
  %
  %   opt = checkOptions(opt)
  %
  % :param opt: structure or json filename containing the options.
  % :type opt: structure
  %
  % :returns:
  %
  % - :opt: the option structure with missing values filled in by the defaults.
  %
  % IMPORTANT OPTIONS (with their defaults):
  %
  %     - ``opt.taskName``
  %
  %     - ``opt.dir``: TODO EXPLAIN
  %
  %     - ``opt.groups = {''}`` - group of subjects to analyze
  %
  %     - ``opt.subjects = {[]}`` - suject to run in each group
  %       space where we conduct the analysis
  %       are located. See ``setDerivativesDir()`` for more information.
  %
  %     - ``opt.space = {'individual', 'MNI'}`` - Space where we conduct the analysis
  %
  %     - ``opt.realign.useUnwarp = true``
  %
  %     - ``opt.useFieldmaps = true`` - when set to ``true`` the
  %       preprocessing pipeline will look for the voxel displacement maps (created by
  %       ``bidsCreateVDM()``) and will use them for realign and unwarp.
  %
  %     - ``opt.model.file = ''`` - path to the BIDS model file that contains the
  %       model to speficy and the contrasts to compute.
  %     - ``'opt.model.designOnly'`` = if set to ``true``, the GLM will be set
  %       up without associating any data to it. Can be useful for quick design matrix
  %       inspection before running estimation.
  %
  %     - ``opt.fwhm.func = 6`` - FWHM to apply to the preprocessed functional images.
  %     - ``opt.fwhm.contrast = 6`` - FWHM to apply to the contrast images before bringing
  %       them at the group level.
  %
  %     - ``opt.query`` - a structure used to specify other options to only run analysis on
  %       certain files. ``struct('dir', 'AP', 'acq' '3p00mm')``. See ``bids.query``
  %       to see how to specify.
  %
  % OTHER OPTIONS (with their defaults):
  %
  %     - ``opt.verbosity = 1;`` - Set it to ``0`` if you want to see less output on the prompt.
  %
  %     - ``opt.dryRun = false`` - Set it to ``true`` in case you don't want to run the analysis.
  %
  %     - ``opt.pipeline.type = 'preproc'`` - Switch it to ``stats`` when running GLMs.
  %     - ``opt.pipeline.name``
  %
  %     - ``opt.zeropad = 2`` - number of zeros used for padding subject numbers, in case
  %       subjects should be fetched by their number ``1`` and not their label ``O1'``.
  %
  %     - ``opt.anatReference.type = 'T1w'`` -  type of the anatomical reference
  %     - ``opt.anatReference.session = ''`` - session label of the anatomical reference
  %
  %     - ``opt.segment.force = false`` - set to ``true`` to ignore previous output
  %       of the segmentation and force to run it again
  %
  %     - ``opt.skullstrip.mean = false`` - to skulstrip mean functional image
  %     - ``opt.skullstrip.threshold = 0.75`` - Threshold used for the skull stripping.
  %       Any voxel with ``p(grayMatter) +  p(whiteMatter) + p(CSF) > threshold``
  %       will be included in the mask.
  %
  %     - ``opt.funcVoxelDims = []`` - Voxel dimensions to use for resampling of functional data
  %       at normalization.
  %
  %     - ``opt.stc.skip = false`` - boolean flag to skip slice time correction or not.
  %     - ``opt.stc.referenceSlice = []`` - reference slice for the slice timing correction.
  %       If left emtpy the mid-volume acquisition time point will be selected at run time.
  %     - ``opt.stc.sliceOrder = []`` - To be used if SPM can't extract slice info. NOT RECOMMENDED,
  %       if you know the order in which slices were acquired, you should be able to recompute
  %       slice timing and add it to the json files in your BIDS data set.
  %
  %     - ``opt.glm.roibased.do = false`` must be set to ``true`` to use the
  %       ``bidsRoiBasedGLM`` workflow
  %     - ``opt.glm.maxNbVols = Inf`` sets the maximum number of volumes to
  %       include in a run in a subject level GLM. This can be useful if some
  %       time series have more volumes than necessary.
  %
  %     - ``opt.QA.func.carpetPlot = true`` to plot carpet plot when running ``functionaQA``
  %     - ``opt.QA.func`` contains a lot of options used by ``spmup_first_level_qa``
  %       in ``functionaQA``
  %     - ``opt.QA.func.MotionParameters = 'on'``
  %     - ``opt.QA.func.FramewiseDisplacement = 'on'``
  %     - ``opt.QA.func.Voltera = 'on'``
  %     - ``opt.QA.func.Globals = 'on'``
  %     - ``opt.QA.func.Movie = 'on'`` ; set it to ``off`` to skip generating movies
  %       of the time series
  %     - ``opt.QA.func.Basics = 'on'``
  %
  %     - ``opt.QA.glm.do = true`` - If set to ``true`` the residual images of a
  %       GLM at the subject levels will be used to estimate if there is any remaining structure
  %       in the GLM residuals (the power spectra are not flat) that could indicate
  %       the subject level results are likely confounded (see
  %       ``plot_power_spectra_of_GLM_residuals`` and `Accurate autocorrelation modeling
  %       substantially improves fMRI reliability
  %       <https://www.nature.com/articles/s41467-019-09230-w.pdf>`_ for more info.
  %
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  fieldsToSet = setDefaultOption();
  opt = setFields(opt, fieldsToSet);

  %  Options for toolboxes
  global ALI_TOOLBOX_PRESENT

  checkToolbox('ALI');
  if ALI_TOOLBOX_PRESENT
    opt = setFields(opt, ALI_my_defaults());
  end

  opt = setFields(opt, rsHRF_my_defaults());

  checkFields(opt);

  if any(strcmp(opt.pipeline.name, {'cpp_spm-stats', 'cpp_spm-preproc'}))
    opt.pipeline.name = 'cpp_spm';
  end

  if ~iscell(opt.query.modality)
    tmp = opt.query.modality;
    opt.query = rmfield(opt.query, 'modality');
    opt.query.modality{1} = tmp;
  end

  if isfield(opt, 'taskName') && ~iscell(opt.taskName)
    opt.taskName = {opt.taskName};
  end

  if ~iscell(opt.space)
    opt.space = {opt.space};
  end

  opt = orderfields(opt);

  opt = setDirectories(opt);

  if ~isempty(opt.model.file) && exist(opt.model.file, 'file') ~= 2
    error('model file does not exist:\n %s', opt.model.file);
  end

  % TODO
  % add some checks on the content of
  % opt.result.Nodes().Output

end

function fieldsToSet = setDefaultOption()

  % this defines the missing fields

  fieldsToSet.verbosity = 1;
  fieldsToSet.dryRun = false;

  fieldsToSet.pipeline.type = 'preproc';
  fieldsToSet.pipeline.name = 'cpp_spm';

  fieldsToSet.useBidsSchema = false;

  fieldsToSet.fwhm.func = 6;
  fieldsToSet.fwhm.contrast = 6;

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

  fieldsToSet.query.modality = {'anat', 'func'};

  fieldsToSet.anatReference.type = 'T1w';
  fieldsToSet.anatReference.session = '';

  %% Options for slice time correction
  % all in seconds
  fieldsToSet.stc.referenceSlice = [];
  fieldsToSet.stc.sliceOrder = [];
  fieldsToSet.stc.skip = false;

  %% Options for realign
  fieldsToSet.realign.useUnwarp = true;
  fieldsToSet.useFieldmaps = true;

  %% Options for segmentation
  fieldsToSet.segment.force = false;

  %% Options for skullstripping
  fieldsToSet.skullstrip.threshold = 0.75;
  fieldsToSet.skullstrip.mean = false;

  %% Options for normalize
  fieldsToSet.space = {'individual', 'MNI'};
  fieldsToSet.funcVoxelDims = [];

  %% Options for model specification and results
  fieldsToSet.model.file = '';
  fieldsToSet.model.designOnly = false;
  fieldsToSet.contrastList = {};

  fieldsToSet.QA.glm.do = true;
  fieldsToSet.QA.func.carpetPlot = true;
  fieldsToSet.QA.func.Motion = 'on';
  fieldsToSet.QA.func.FD = 'on';
  fieldsToSet.QA.func.Voltera = 'on';
  fieldsToSet.QA.func.Globals = 'on';
  fieldsToSet.QA.func.Movie = 'on';
  fieldsToSet.QA.func.Basics = 'on';

  fieldsToSet.glm.roibased.do = false;
  fieldsToSet.glm.maxNbVols = Inf;

  % specify the results to compute
  fieldsToSet.result.Nodes = returnDefaultResultsStructure();

end

function checkFields(opt)

  if isfield(opt, 'taskName') && isempty(opt.taskName)

    msg = 'You may need to provide the name of the task to analyze.';
    errorHandling(mfilename(), 'noTask', msg, true, opt.verbosity);

  end

  if ~all(cellfun(@ischar, opt.groups))

    msg = 'All group names should be string.';
    errorHandling(mfilename(), 'groupNotString', msg, false, opt.verbosity);

  end

  if ~ischar(opt.anatReference.session)

    msg = 'The session label should be string.';
    errorHandling(mfilename(), 'sessionNotString', msg, false, opt.verbosity);

  end

  if ~isempty(opt.stc.referenceSlice) && length(opt.stc.referenceSlice) > 1

    msg = sprintf( ...
                  ['options.stc.referenceSlice should be a scalar.' ...
                   '\nCurrent value is: %d'], ...
                  opt.stc.referenceSlice);
    errorHandling(mfilename(), 'refSliceNotScalar', msg, false, opt.verbosity);

  end

  if ~isempty (opt.funcVoxelDims) && length(opt.funcVoxelDims) ~= 3

    msg = sprintf( ...
                  ['opt.funcVoxelDims should be a vector of length 3. '...
                   '\nCurrent value is: %d'], ...
                  opt.funcVoxelDims);
    errorHandling(mfilename(), 'voxDim', msg, false, opt.verbosity);

  end

  if isfield(opt.model, 'hrfDerivatives')

    msg = ('HRF derivatives should be set in the BIDS stats model file, not in the options.');
    errorHandling(mfilename(), 'voxDim', msg, true, opt.verbosity);

  end

end
