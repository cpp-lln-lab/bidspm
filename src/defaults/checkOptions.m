% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

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
  %   - ``opt.taskName``
  %   - ``opt.dataDir``
  %
  % IMPORTANT OPTIONS (with their defaults):
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
  %   - ``opt.zeropad = 2`` - number of zeros used for padding subject numbers, in case
  %     subjects should be fetched by their number ``1`` and not their label ``O1'``.
  %   - ``opt.anatReference.type = 'T1w'`` -  type of the anatomical reference
  %   - ``opt.anatReference.session = 1`` - session number of the anatomical reference
  %   - ``opt.skullstrip.threshold = 0.75`` - Threshold used for the skull stripping.
  %     Any voxel with ``p(grayMatter) +  p(whiteMatter) + p(CSF) > threshold``
  %     will be included in the mask.
  %   - ``opt.funcVoxelDims = []`` - Voxel dimensions to use for resampling of functional data
  %     at normalization.
  %   - ``opt.STC_referenceSlice = []`` - reference slice for the slice timing correction.
  %     If left emtpy the mid-volume acquisition time point will be selected at run time.
  %   - ``opt.sliceOrder = []`` - To be used if SPM can't extract slice info. NOT RECOMMENDED:
  %     if you know the order in which slices were acquired, you should be able to recompute
  %     slice timing and add it to the json files in your BIDS data set.
  %

  fieldsToSet = setDefaultOption();

  opt = setDefaultFields(opt, fieldsToSet);

  checkFields(opt);

  if ~isempty(opt.dataDir)
    opt.dataDir = abspath(opt.dataDir);
  end

  opt = orderfields(opt);

end

function fieldsToSet = setDefaultOption()
  % this defines the missing fields

  fieldsToSet.dataDir = '';
  fieldsToSet.derivativesDir = '';

  fieldsToSet.groups = {''};
  fieldsToSet.subjects = {[]};
  fieldsToSet.zeropad = 2;

  fieldsToSet.anatReference.type = 'T1w';
  fieldsToSet.anatReference.session = [];

  %% Options for slice time correction
  fieldsToSet.STC_referenceSlice = [];
  fieldsToSet.sliceOrder = [];

  %% Options for realign
  fieldsToSet.realign.useUnwarp = true;
  fieldsToSet.useFieldmaps = true;

  %% Options for segmentation
  fieldsToSet.skullstrip.threshold = 0.75;

  %% Options for normalize
  fieldsToSet.space = 'MNI';
  fieldsToSet.funcVoxelDims = [];

  %% Options for model specification and results
  fieldsToSet.model.file = '';
  fieldsToSet.model.hrfDerivatives = [0 0];
  fieldsToSet.contrastList = {};

  % specify the results to compute
  fieldsToSet.result.Steps = struct( ...
                                    'Level',  '', ... % dataset, run, subject
                                    'Contrasts', struct( ...
                                                        'Name', '', ...
                                                        'Mask', false, ...
                                                        'MC', 'FWE', ... % FWE, none, FDR
                                                        'p', 0.05, ...
                                                        'k', 0, ...
                                                        'NIDM', true));

  opt.parallelize.do = false;
  opt.parallelize.nbWorkers = 3;
  opt.parallelize.killOnExit = true;

end

function checkFields(opt)

  if ~isfield(opt, 'taskName') || isempty(opt.taskName)

    errorStruct.identifier = 'checkOptions:noTask';
    errorStruct.message = sprintf( ...
                                  'Provide the name of the task to analyze.');
    error(errorStruct);

  end

  if ~all(cellfun(@ischar, opt.groups))

    disp(opt.groups);

    errorStruct.identifier = 'checkOptions:groupNotString';
    errorStruct.message = sprintf( ...
                                  'All group names should be string.');
    error(errorStruct);

  end

  if ~isempty (opt.STC_referenceSlice) && length(opt.STC_referenceSlice) > 1

    errorStruct.identifier = 'checkOptions:refSliceNotScalar';
    errorStruct.message = sprintf( ...
                                  ['options.STC_referenceSlice should be a scalar.' ...
                                   '\nCurrent value is: %d'], ...
                                  opt.STC_referenceSlice);
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
