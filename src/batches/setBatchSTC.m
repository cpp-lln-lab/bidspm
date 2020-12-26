% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subID)
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
  % Slice timing units is in milliseconds to be BIDS compliant and not in slice number
  % as is more traditionally the case with SPM.
  %
  % In the case the slice timing information was not specified in the json FILES
  % in the BIDS data set (e.g it couldnt be extracted from the trento old scanner),
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

  maxSliceTime = max(sliceOrder);
  minSliceTime = min(sliceOrder);
  if isempty(opt.STC_referenceSlice)
    referenceSlice = (maxSliceTime - minSliceTime) / 2;
  else
    referenceSlice = opt.STC_referenceSlice;
  end
  if referenceSlice > TA
    error('%s (%f) %s (%f).\n%s', ...
          'The reference slice time', referenceSlice, ...
          'is greater than the acquisition time', TA, ...
          ['Reference slice time must be in milliseconds ' ...
           'or leave it empty to use mid-acquisition time as reference.']);
  end
  
  matlabbatch{end+1}.spm.temporal.st.nslices = nbSlices;
  matlabbatch{end}.spm.temporal.st.tr = TR;
  matlabbatch{end}.spm.temporal.st.ta = TA;
  matlabbatch{end}.spm.temporal.st.so = sliceOrder;
  matlabbatch{end}.spm.temporal.st.refslice = referenceSlice;
  

  [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

  runCounter = 1;

  for iSes = 1:nbSessions

    % get all runs for that subject for this session
    [runs, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      % get the filename for this bold run for this task
      [fileName, subFuncDataDir] = getBoldFilename( ...
                                                   BIDS, ...
                                                   subID, sessions{iSes}, runs{iRun}, opt);

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
