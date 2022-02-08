function opt = checkOptions(opt)
  %
  % Check the option inputs and add any missing field with some defaults
  %
  % Then it will search the derivatives directory for any zipped ``*.gz`` image
  % and uncompress the files for the task of interest.
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
  % REQUIRED FIELDS:
  %
  %   - ``opt.taskName``
  %   - ``opt.dataDir``
  %
  % IMPORTANT OPTIONS (with their defaults):
  %
  %   - ``opt.groups = {''}`` - group of subjects to analyze
  %   - ``opt.subjects = {[]}`` - suject to run in each group
  %     space where we conduct the analysis
  %   - ``opt.derivativesDir = ''`` - directory where the raw and derivatives
  %     are located. See ``setDerivativesDir()`` for more information.
  %   - ``opt.space = 'MNI'`` - Space where we conduct the analysis
  %   - ``opt.realign.useUnwarp = true``
  %   - ``opt.useFieldmaps = true`` - when set to ``true`` the
  %     preprocessing pipeline will look for the voxel displacement maps (created by
  %     ``bidsCreateVDM()``) and will use them for realign and unwarp.
  %   - ``opt.model.file = ''`` - path to the BIDS model file that contains the
  %     model to speficy and the contrasts to compute.
  %
  % OTHER OPTIONS (with their defaults):
  %
  %     - ``opt.zeropad = 2`` - number of zeros used for padding subject numbers, in case
  %         subjects should be fetched by their number ``1`` and not their label ``O1'``.
  %     - ``opt.query`` - a structure used to specify other options to only run analysis on
  %         certain files. ``struct('dir', 'AP', 'acq' '3p00mm')``. See ``bids.query``
  %         to see how to specify.
  %     - ``opt.anatReference.type = 'T1w'`` -  type of the anatomical reference
  %     - ``opt.anatReference.session = ''`` - session label of the anatomical reference
  %     - ``opt.skullstrip.threshold = 0.75`` - Threshold used for the skull stripping.
  %         Any voxel with ``p(grayMatter) +  p(whiteMatter) + p(CSF) > threshold``
  %         will be included in the mask.
  %     - ``opt.funcVoxelDims = []`` - Voxel dimensions to use for resampling of functional data
  %         at normalization.
  %     - ``opt.stc.skip = false`` - boolean flag to skip slice time correction or not.
  %     - ``opt.stc.referenceSlice = []`` - reference slice for the slice timing correction.
  %         If left emtpy the mid-volume acquisition time point will be selected at run time.
  %     - ``opt.stc.sliceOrder = []`` - To be used if SPM can't extract slice info. NOT RECOMMENDED,
  %         if you know the order in which slices were acquired, you should be able to recompute
  %         slice timing and add it to the json files in your BIDS data set.
  %     -  ``opt.glm.roibased.do``
  %     -  ``opt.QA.func.carpetPlot = true`` to plot carpet plot when running ``functionaQA``
  %     -  ``opt.QA.func`` contains a lot of options used by ``spmup_first_level_qa``
  %         in ``functionaQA``
  %     -  ``opt.QA.func.MotionParameters = 'on'``
  %     -  ``opt.QA.func.FramewiseDisplacement = 'on'``
  %     -  ``opt.QA.func.Voltera = 'on'``
  %     -  ``opt.QA.func.Globals = 'on'``
  %     -  ``opt.QA.func.Movie = 'on'`` ; set it to ``off`` to skip generating movies
  %         of the time series
  %     -  ``opt.QA.func.Basics = 'on'``
  %     -  ``opt.QA.glm.do = true`` - If set to ``true`` the residual images of a
  %         GLM at the subject levels will be used to estimate if there is any remaining structure
  %         in the GLM residuals (the power spectra are not flat) that could indicate
  %         the subject level results are likely confounded (see
  %         ``plot_power_spectra_of_GLM_residuals`` and `Accurate autocorrelation modeling
  %         substantially improves fMRI reliability
  %         <https://www.nature.com/articles/s41467-019-09230-w.pdf>`_ for more info.
  %
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  fieldsToSet = setDefaultOption();
  opt = setFields(opt, fieldsToSet);

  opt = setFields(opt, fieldsToSet);

  %  Options for toolboxes
  global ALI_TOOLBOX_PRESENT

  checkToolbox('ALI');
  if ALI_TOOLBOX_PRESENT
    opt = setFields(opt, ALI_my_defaults());
  end

  checkFields(opt);

  if ~isempty(opt.dataDir)
    opt.dataDir = spm_file(opt.dataDir, 'cpath');
  end

  opt = orderfields(opt);

  opt = setStatsDir(opt);

end

function fieldsToSet = setDefaultOption()
  % this defines the missing fields

  fieldsToSet.dataDir = '';
  fieldsToSet.derivativesDir = '';
  fieldsToSet.dir = struct('raw', '', ...
                           'derivatives', '');

  fieldsToSet.groups = {''};
  fieldsToSet.subjects = {[]};
  fieldsToSet.zeropad = 2;

  fieldsToSet.query = struct([]);

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
  fieldsToSet.skullstrip.threshold = 0.75;
  fieldsToSet.skullstrip.mean = false;

  %% Options for normalize
  fieldsToSet.space = 'MNI';
  fieldsToSet.funcVoxelDims = [];

  %% Options for model specification and results
  fieldsToSet.model.file = '';
  fieldsToSet.model.hrfDerivatives = [0 0];
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

  % specify the results to compute
  fieldsToSet.result.Steps = returnDefaultResultsStructure();

  fieldsToSet.parallelize.do = false;
  fieldsToSet.parallelize.nbWorkers = 2;
  fieldsToSet.parallelize.killOnExit = false;

end

function checkFields(opt)

  if isfield(opt, 'taskName') && isempty(opt.taskName)

    errorStruct.identifier = 'checkOptions:noTask';
    errorStruct.message = sprintf( ...
                                  'Provide the name of the task to analyze.');
    error(errorStruct);

  end

  if ~all(cellfun(@ischar, opt.groups))

    errorStruct.identifier = 'checkOptions:groupNotString';
    errorStruct.message = sprintf( ...
                                  'All group names should be string.');
    error(errorStruct);

  end

  if ~ischar(opt.anatReference.session)

    errorStruct.identifier = 'checkOptions:sessionNotString';
    errorStruct.message = sprintf( ...
                                  'The session label should be string.');
    error(errorStruct);

  end

  if ~isempty (opt.stc.referenceSlice) && length(opt.stc.referenceSlice) > 1

    errorStruct.identifier = 'checkOptions:refSliceNotScalar';
    errorStruct.message = sprintf( ...
                                  ['options.stc.referenceSlice should be a scalar.' ...
                                   '\nCurrent value is: %d'], ...
                                  opt.stc.referenceSlice);
    error(errorStruct);

  end

  if ~isempty (opt.funcVoxelDims) && length(opt.funcVoxelDims) ~= 3

    errorStruct.identifier = 'checkOptions:voxDim';
    errorStruct.message = sprintf( ...
                                  ['opt.funcVoxelDims should be a vector of length 3. '...
                                   '\nCurrent value is: %d'], ...
                                  opt.funcVoxelDims);
    error(errorStruct);

  end

end
