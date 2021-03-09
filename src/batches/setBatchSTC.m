% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel)
  %
  % Creates batch for slice timing correction
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subID)
  %
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param subID: subject ID
  % :type subID: string
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

  % get slice order
  sliceOrder = getSliceOrder(opt, 1);
  if isempty(sliceOrder)
    warning('No slice order dectected: skipping slice timing correction.');
    return
  end

  printBatchName('slice timing correction');

  % get metadata for STC
  % Note that slice ordering is assumed to be from foot to head. If it is not, enter
  % instead: TR - INTRASCAN_TIME - SLICE_TIMING_VECTOR

  % SPM accepts slice time acquisition as inputs for slice order (simplifies
  % things when dealing with multiecho data)
  nbSlices = length(sliceOrder); % unique is necessary in case of multi echo
  TR = opt.metadata.RepetitionTime;
  TA = TR - (TR / nbSlices);
  % round acquisition time to the upper millisecond
  % mostly to avoid having errors when checking:
  %     any(sliceOrder > TA)
  TA = ceil(TA * 1000)/1000;

  maxSliceTime = max(sliceOrder);
  minSliceTime = min(sliceOrder);
  if isempty(opt.STC_referenceSlice)
    referenceSlice = (maxSliceTime - minSliceTime) / 2;
  else
    referenceSlice = opt.STC_referenceSlice;
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

    errorStruct.identifier = 'setBatchSTC:invalidInputTime';
    errorStruct.message = msg;
    error(errorStruct);
  end

  matlabbatch{end + 1}.spm.temporal.st.nslices = nbSlices;
  matlabbatch{end}.spm.temporal.st.tr = TR;
  matlabbatch{end}.spm.temporal.st.ta = TA;
  matlabbatch{end}.spm.temporal.st.so = sliceOrder * 1000;
  matlabbatch{end}.spm.temporal.st.refslice = referenceSlice * 1000;

  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

  runCounter = 1;

  for iSes = 1:nbSessions

    % get all runs for that subject for this session
    [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      % get the filename for this bold run for this task
      [fileName, subFuncDataDir] = getBoldFilename( ...
                                                   BIDS, ...
                                                   subLabel, sessions{iSes}, runs{iRun}, opt);

      % check that the file with the right prefix exist
      file = validationInputFile(subFuncDataDir, fileName);

      % add the file to the list
      matlabbatch{end}.spm.temporal.st.scans{runCounter} = {file};

      runCounter = runCounter + 1;

      disp(file);

    end

  end

  % The following lines are commented out because those parameters
  % can be set in the spm_my_defaults.m
  % matlabbatch{1}.spm.temporal.st.prefix = spm_get_defaults('slicetiming.prefix');

end
