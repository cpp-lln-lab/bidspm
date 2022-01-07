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
  % If no slice order can be found, the slice timing correction will not be performed.
  %
  % If not specified this function will take the mid-volume time point as reference
  % to do the slice timing correction.
  %
  % (C) Copyright 2019 CPP_SPM developers

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

  files = bids.query(BIDS, 'data', filter);

  runCounter = 1;

  for iFile = 1:size(files, 1)

    % TODO check for eventually zipped files
    file = unzipAndReturnsFullpathName(files{iFile}, opt);
    temporal.st.scans{runCounter} = {file};

    runCounter = runCounter + 1;

    printToScreen([files{iFile}, '\n'], opt);

  end

  matlabbatch{end + 1}.spm.temporal = temporal;

end
