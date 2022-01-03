function matlabbatch = setBatchSTC(varargin)
  %
  % Creates batch for slice timing correction
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel)
  %
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param subLabel: subject label
  % :type subLabel: string
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %
  % Slice timing units is in seconds to be BIDS compliant and not in slice number
  % as is more traditionally the case with SPM.
  %
  % In the case the slice timing information was not specified in the json FILES
  % in the BIDS data set (e.g it couldn't be extracted from the trento old scanner),
  % then add this information manually in opt.sliceOrder field.
  %
  % If this is empty the slice timing correction will not be performed
  %
  % If not specified this function will take the mid-volume time point as reference
  % to do the slice timing correction
  %
  % (C) Copyright 2019 CPP_SPM developers

  % TODO with multitask support it is even more needed to check
  % that all files have the same slice timing and that might not be the case
  % reflected in opt.metadata

  p = inputParser;

  addRequired(p, 'matlabbatch', @iscell);
  addRequired(p, 'BIDS', @isstruct);
  addRequired(p, 'opt', @isstruct);
  addRequired(p, 'subLabel', @ischar);

  parse(p, varargin{:});

  matlabbatch = p.Results.matlabbatch;
  BIDS = p.Results.BIDS;
  opt = p.Results.opt;
  subLabel = p.Results.subLabel;

  if opt.stc.skip
    return
  end

  % get metadata for STC

  % only stick to raw data
  opt.query.space = '';
  opt.query.desc = '';

  filter = opt.query;
  filter.sub =  subLabel;
  filter.suffix = 'bold';
  filter.extension = {'.nii', '.nii.gz'};
  filter.prefix = '';
  % in case task was not passed through opt.query
  if ~isfield(filter, 'task')
    filter.task = opt.taskName;
  end

  TR = getAndCheckRepetitionTime(BIDS, filter);

  % get slice order
  sliceOrder = getAndCheckSliceOrder(BIDS, opt, filter);
  if isempty(sliceOrder)
    errorHandling(mfilename(), 'noSliceOrder', ...
                  'skipping slice timing correction.', ...
                  true, opt.verbosity);
    return
  end

  printBatchName('slice timing correction', opt);

  % SPM accepts slice time acquisition as inputs for slice order
  % (simplifies things when dealing with multiecho data)
  nbSlices = length(sliceOrder);
  TA = TR - (TR / nbSlices);
  % round acquisition time to the upper millisecond
  % mostly to avoid having errors when checking:
  %     any(sliceOrder > TA)
  TA = ceil(TA * 1000) / 1000;

  maxSliceTime = max(sliceOrder);
  minSliceTime = min(sliceOrder);

  if isempty(opt.stc.referenceSlice)
    referenceSlice = (maxSliceTime - minSliceTime) / 2;
  else
    referenceSlice = opt.stc.referenceSlice;
  end

  if TA >= TR || referenceSlice > TA || any(sliceOrder > TA)

    pattern = repmat ('%.3f, ', 1, numel(sliceOrder));
    pattern(end) = [];

    msg = sprintf([ ...
                   'Impossible values on slice timing input:\n\n', ...
                   '  repetition time > acquisition time > reference slice.\n\n', ...
                   'All STC values in the opt structure must be in seconds.\n', ...
                   'Current values:', ...
                   '\n- repetition time: %f', ...
                   '\n- acquisition time: %f', ...
                   '\n- reference slice: %f', ...
                   '\n- slice order: ' pattern], TR, TA, referenceSlice, sliceOrder);

    errorHandling(mfilename(), 'invalidInputTime', msg, ...
                  false, opt.verbosity);
  end

  temporal.st.nslices = nbSlices;
  temporal.st.tr = TR;
  temporal.st.ta = TA;
  temporal.st.so = sliceOrder * 1000;
  temporal.st.refslice = referenceSlice * 1000;

  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

  runCounter = 1;

  % TODO refactor by using a single bids.query and unzip anything that needs to
  % to be unzipped
  for iSes = 1:nbSessions

    % get all runs for that subject for this session
    [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      % get the filename for this bold run for this task
      [fileName, subFuncDataDir] = getBoldFilename( ...
                                                   BIDS, ...
                                                   subLabel, sessions{iSes}, runs{iRun}, opt);

      file = validationInputFile(subFuncDataDir, fileName);

      % add the file to the list
      temporal.st.scans{runCounter} = {file};

      runCounter = runCounter + 1;

      printToScreen([file, '\n'], opt);

    end

  end

  matlabbatch{end + 1}.spm.temporal = temporal;

end
