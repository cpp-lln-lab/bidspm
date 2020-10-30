% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function opt = checkOptions(opt)
  % opt = checkOptions(opt)
  %
  % we check the option inputs and add any missing field with some defaults

  fieldsToSet = setDefaultOption();

  opt = setDefaultFields(opt, fieldsToSet);

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

  opt = orderfields(opt);

end

function fieldsToSet = setDefaultOption()
  % this defines the missing fields

  % group of subjects to analyze
  fieldsToSet.groups = {''};
  % suject to run in each group
  fieldsToSet.subjects = {[]};
  fieldsToSet.zeropad = 2;

  % session number and type of the anatomical reference
  fieldsToSet.anatReference.type = 'T1w';
  fieldsToSet.anatReference.session = 1;

  % any voxel with p(grayMatter) +  p(whiteMatter) + p(CSF) > threshold
  % will be included in the skull stripping mask
  fieldsToSet.skullstrip.threshold = 0.75;

  % space where we conduct the analysis
  fieldsToSet.space = 'MNI';

  % The directory where the raw and derivatives are located
  fieldsToSet.dataDir = '';
  fieldsToSet.derivativesDir = '';

  % Options for slice time correction
  % If left unspecified the slice timing will be done using the mid-volume acquisition
  % time point as reference.
  % Slice order must be entered in time unit (ms) (this is the BIDS way of doing things)
  % instead of the slice index of the reference slice (the "SPM" way of doing things).
  % More info here: https://en.wikibooks.org/wiki/SPM/Slice_Timing
  fieldsToSet.STC_referenceSlice = []; % reference slice: middle acquired slice
  fieldsToSet.sliceOrder = []; % To be used if SPM can't extract slice info

  % fieldsToSet for normalize
  % Voxel dimensions for resampling at normalization of functional data or leave empty [ ].
  fieldsToSet.funcVoxelDims = [];

  % specify the model file that contains the contrasts to compute
  fieldsToSet.contrastList = {};
  fieldsToSet.model.file = '';

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

end
