function [group, opt, BIDS] = getData(opt, BIDSdir, type)
    % getData checks that all the options specified by the user in getOptions
    % and fills the blank for any that might have been missed out.
    % It then reads the specified BIDS data set and gets the groups and
    % subjects to analyze. This can be specified in the opt structure in
    % different ways:
    % Set the group of subjects to analyze.
    % opt.groups = {'control', 'blind'};
    %
    % If there are no groups (i.e subjects names are of the form `sub-01` for
    % example) or if you want to run all subjects of all groups then use:
    % opt.groups = {''};
    % opt.subjects = {[]};
    %
    % If you have 2 groups (`cont` and `cat` for example) the following will
    % run cont01, cont02, cat03, cat04.
    % opt.groups = {'cont', 'cat'};
    % opt.subjects = {[1 2], [3 4]};
    %
    % If you have more than 2 groups but want to only run the subjects of 2
    % groups then you can use.
    % opt.groups = {'cont', 'cat'};
    % opt.subjects = {[], []};
    %
    % You can also directly specify the subject label for the participants you want to run
    % opt.groups = {''};
    % opt.subjects = {'01', 'cont01', 'cat02', 'ctrl02', 'blind01'};
    %
    % You can also specify:
    %  - BIDSdir: the directory where the data is ; default is fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL')
    %  - type: the data type you want to get the metadata of ; supported: bold (default) and T1w
    %
    %  IMPORTANT NOTE: if you specify the type variable for T1w then you must
    %  make sure that the T1w.json is also present in the anat folder because
    %  of the way the spm_BIDS function works at the moment

    if nargin < 3 || (exist('type', 'var') && isempty(type))
        type = 'bold';
    end

    opt = checkOptions(opt);

    if nargin < 2 || (exist('BIDSdir', 'var') && isempty(BIDSdir))
        % The directory where the derivatives are located
        derivativesDir = fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL');
    else
        derivativesDir = BIDSdir;
    end

    fprintf(1, 'FOR TASK: %s\n', opt.taskName);

    % we let SPM figure out what is in this BIDS data set
    BIDS = spm_BIDS(derivativesDir);

    % make sure that the required tasks exist in the data set
    if ~ismember(opt.taskName, spm_BIDS(BIDS, 'tasks'))
        fprintf('List of tasks present in this dataset:\n');
        spm_BIDS(BIDS, 'tasks');
        error('The task %s that you have asded for does not exist in this data set.');
    end

    % get IDs of all subjects
    subjects = spm_BIDS(BIDS, 'subjects');

    % get metadata for bold runs for that task
    % we take those from the first run of the first subject assuming it can
    % apply to all others.

    % THIS NEEDS FIXING AS WE MIGHT WANT THE METADATA OF THE SUBJECTS SELECTED
    % RATHER THAN THE FIRST SUBJECT OF THE DATASET

    switch type
        case 'bold'
            metadata = spm_BIDS(BIDS, 'metadata', ...
                'task', opt.taskName, ...
                'sub', subjects{1}, ...
                'type', type);
        case 'T1w'
            metadata = spm_BIDS(BIDS, 'metadata', ...
                'sub', subjects{1}, ...
                'type', [type]);
    end

    if iscell(metadata)
        opt.metadata = metadata{1};
    else
        opt.metadata = metadata;
    end

    %% Add the different groups in the experiment
    for iGroup = 1:numel(opt.groups) % for each group

        clear idx;

        % Name of the group
        group(iGroup).name = opt.groups{iGroup}; %#ok<*AGROW>

        % if no group or subject was specified we take all of them
        if numel(opt.groups) == 1 && strcmp(group(iGroup).name, '') && isempty(opt.subjects{iGroup})

            group(iGroup).subNumber = subjects;

            % if subject ID were directly specified by users we take those
        elseif strcmp(group(iGroup).name, '') && iscellstr(opt.subjects)

            group(iGroup).subNumber = opt.subjects;

            % if group was specified we figure out which subjects to take
        elseif ~isempty(opt.subjects{iGroup})

            idx = opt.subjects{iGroup};

            % else we take all subjects of that group
        elseif isempty(opt.subjects{iGroup})

            % count how many subjects in that group
            idx = sum(~cellfun(@isempty, strfind(subjects, group(iGroup).name)));
            idx = 1:idx;

        else

            error('Not sure what to do.');

        end

        % if only indices were specified we get the subject from that group with that
        if exist('idx', 'var')
            pattern = [group(iGroup).name '%0' num2str(opt.zeropad) '.0f_'];
            temp = strsplit(sprintf(pattern, idx), '_');
            group(iGroup).subNumber = temp(1:end - 1);
        end

        % check that all the subjects asked for exist
        if ~all(ismember(group(iGroup).subNumber, subjects))
            fprintf('subjects specified\n');
            disp(group(iGroup).subNumber);
            fprintf('subjects present\n');
            disp(subjects);
            error('Some of the subjects specified do not exist in this data set. This can be due to wrong zero padding: see opt.zeropad in getOptions');
        end

        % Number of subjects in the group
        group(iGroup).numSub = length(group(iGroup).subNumber) ;

        fprintf(1, 'WILL WORK ON SUBJECTS\n');
        disp(group(iGroup).subNumber);
    end

end

function opt = checkOptions(opt)
    % we check the option inputs and add any missing field with some defaults

    options = getDefaultOption();

    % update options with user input
    % --------------------------------
    I = intersect(fieldnames(options), fieldnames(opt));

    for f = 1:length(I)
        options = setfield(options, I{f}, getfield(opt, I{f})); %#ok<GFLD,SFLD>
    end

    if ~all(cellfun(@ischar, options.groups))
        disp(options.groups);
        error('All group names should be string.');
    end

    if ~isempty (options.STC_referenceSlice) && length(options.STC_referenceSlice) > 1
        error('options.STC_referenceSlice should be a scalar and current value is: %d', options.STC_referenceSlice);
    end

    if ~isempty (options.funcVoxelDims) && length(options.funcVoxelDims) ~= 3
        error('opt.funcVoxelDims should be a vector of length 3 and current value is: %d', opt.funcVoxelDims);
    end

    opt = options;

end

function options = getDefaultOption()
    % this defines the missing fields

    % group of subjects to analyze
    options.groups = {''};
    % suject to run in each group
    options.subjects = {[]};
    options.zeropad = 2;

    % task to analyze
    options.taskName = '';

    % The directory where the derivatives are located
    options.dataDir = '';

    % Options for slice time correction
    options.STC_referenceSlice = []; % reference slice: middle acquired slice
    options.sliceOrder = []; % To be used if SPM can't extract slice info

    % Options for normalize
    % Voxel dimensions for resampling at normalization of functional data or leave empty [ ].
    options.funcVoxelDims = [];

    % Suffix output directory for the saved jobs
    options.JOBS_dir = '';

    % specify the model file that contains the contrasts to compute
    options.contrastList = {};
    options.model.file = '';

    % specify the results to compute
    options.result.Steps = [];
end
