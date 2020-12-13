% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function [group, opt, BIDS] = getData(opt, BIDSdir, type)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % [group, opt, BIDS] = getData(opt, BIDSdir, type)
  %
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
  %  - BIDSdir: the directory where the data is ; default is :
  %     fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL')
  %  - type: the data type you want to get the metadata of ;
  %     supported: bold (default) and T1w
  %
  %  TODO: Check if the following is true? Ideally write a test to make sure.
  %  IMPORTANT NOTE: if you specify the type variable for T1w then you must
  %  make sure that the T1w.json is also present in the anat folder because
  %  of the way the bids.query function works at the moment

  if nargin < 2 || (exist('BIDSdir', 'var') && isempty(BIDSdir))
    % The directory where the derivatives are located
    opt = setDerivativesDir(opt);
    BIDSdir = opt.derivativesDir;
  end
  derivativesDir = BIDSdir;

  if nargin < 3 || (exist('type', 'var') && isempty(type))
    type = 'bold';
  end

  fprintf(1, 'FOR TASK: %s\n', opt.taskName);

  % we let SPM figure out what is in this BIDS data set
  BIDS = bids.layout(derivativesDir);

  % make sure that the required tasks exist in the data set
  if ~ismember(opt.taskName, bids.query(BIDS, 'tasks'))
    fprintf('List of tasks present in this dataset:\n');
    bids.query(BIDS, 'tasks');

    errorStruct.identifier = 'getData:noMatchingTask';
    errorStruct.message = sprintf( ...
                                  ['The task %s that you have asked for ', ...
                                   'does not exist in this data set.'], opt.taskName);
    error(errorStruct);
  end

  % get IDs of all subjects
  subjects = bids.query(BIDS, 'subjects');

  % get metadata for bold runs for that task
  % we take those from the first run of the first subject assuming it can
  % apply to all others.
  opt = getMetaData(BIDS, opt, subjects, type);

  %% Add the different groups in the experiment
  for iGroup = 1:numel(opt.groups) % for each group

    clear idx;

    % Name of the group
    group(iGroup).name = opt.groups{iGroup}; %#ok<*AGROW>

    group = getSpecificSubjects(opt, group, iGroup, subjects);

    % check that all the subjects asked for exist
    if ~all(ismember(group(iGroup).subNumber, subjects))
      fprintf('subjects specified\n');
      disp(group(iGroup).subNumber);
      fprintf('subjects present\n');
      disp(subjects);

      errorStruct.identifier = 'getData:noMatchingSubject';
      msg = ['Some of the subjects specified do not exist in this data set.' ...
             'This can be due to wrong zero padding: see opt.zeropad in getOptions'];
      errorStruct.message = msg;
      error(errorStruct);
    end

    % Number of subjects in the group
    group(iGroup).numSub = length(group(iGroup).subNumber);

    fprintf(1, 'WILL WORK ON SUBJECTS\n');
    disp(group(iGroup).subNumber);
  end

end

function opt = getMetaData(BIDS, opt, subjects, type)

  % THIS NEEDS FIXING AS WE MIGHT WANT THE METADATA OF THE SUBJECTS SELECTED
  % RATHER THAN THE FIRST SUBJECT OF THE DATASET

  switch type
    case 'bold'
      metadata = bids.query(BIDS, 'metadata', ...
                          'task', opt.taskName, ...
                          'sub', subjects{1}, ...
                          'type', type);
    case 'T1w'
      metadata = bids.query(BIDS, 'metadata', ...
                          'sub', subjects{1}, ...
                          'type', type);
  end

  if iscell(metadata)
    opt.metadata = metadata{1};
  else
    opt.metadata = metadata;
  end

end
