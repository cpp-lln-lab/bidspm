% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchSTC(BIDS, opt, subID)
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
    % See README.md for more information about slice timing correction

    matlabbatch = [];

    % get slice order
    sliceOrder = getSliceOrder(opt, 1);
    if isempty(sliceOrder)
        warning('No slice order dectected: skipping slice timing correction.');
        return
    end

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

    % prefix of the files to look for
    prefix = getPrefix('STC', opt);

    [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

    runCounter = 1;

    for iSes = 1:nbSessions

        % get all runs for that subject across all sessions
        [runs, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

        for iRun = 1:nbRuns

            % get the filename for this bold run for this task
            [fileName, subFuncDataDir] = getBoldFilename( ...
                                                         BIDS, ...
                                                         subID, sessions{iSes}, runs{iRun}, opt);

            % check that the file with the right prefix exist
            files = inputFileValidation(subFuncDataDir, prefix, fileName);

            % add the file to the list
            matlabbatch{1}.spm.temporal.st.scans{runCounter} = cellstr(files);

            runCounter = runCounter + 1;

            disp(files{1});

        end

    end

    matlabbatch{1}.spm.temporal.st.nslices = nbSlices;
    matlabbatch{1}.spm.temporal.st.tr = TR;
    matlabbatch{1}.spm.temporal.st.ta = TA;
    matlabbatch{1}.spm.temporal.st.so = sliceOrder;
    matlabbatch{1}.spm.temporal.st.refslice = referenceSlice;

end
