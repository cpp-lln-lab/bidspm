function [BIDS, opt] = getData(opt, BIDSdir, suffix)
  %
  % Reads the specified BIDS data set and updates the list of subjects to analyze.
  %
  % USAGE::
  %
  %   [BIDS, opt] = getData(opt, [BIDSdir], [type = 'bold'])
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param BIDSdir: the directory where the data is ; default is :
  %                 ``fullfile(opt.dataDir, '..', 'derivatives', 'cpp_spm')``
  % :type BIDSdir: string
  % :param type: the data type you want to get the metadata of;
  %              supported: ``'bold'`` (default) and ``T1w``
  % :type type: string
  %
  % :returns:
  %           - :opt: (structure)
  %           - :BIDS: (structure)
  %
  % .. todo
  %          Check if the following is true? Ideally write a test to make sure.
  %
  %  IMPORTANT NOTE: if you specify the type variable for T1w then you must
  %  make sure that the T1w.json is also present in the anat folder because
  %  of the way the bids.query function works at the moment
  %
  % (C) Copyright 2020 CPP_SPM developers

  if nargin < 2
    errorStruct.identifier = 'getData:noBidsDirectory';
    errorStruct.message = 'Provide a BIDS directory.';
    error(errorStruct);

    error('Provide a BIDS directory.');
  end

  if nargin < 3 || (exist('suffix', 'var') && isempty(suffix))
    suffix = 'bold';
  end

  if isfield(opt, 'taskName')
    fprintf(1, 'FOR TASK: %s\n', opt.taskName);
  else
    suffix = 'T1w';
  end

  BIDS = bids.layout(BIDSdir);

  % make sure that the required tasks exist in the data set
  if isfield(opt, 'taskName') && ~ismember(opt.taskName, bids.query(BIDS, 'tasks'))
    fprintf('List of tasks present in this dataset:\n');
    bids.query(BIDS, 'tasks');

    errorStruct.identifier = 'getData:noMatchingTask';
    errorStruct.message = sprintf( ...
                                  ['The task %s that you have asked for ', ...
                                   'does not exist in this data set.'], opt.taskName);
    error(errorStruct);
  end

  % get IDs of all subjects
  opt = getSubjectList(BIDS, opt);

  % get metadata for bold runs for that task
  % we take those from the first run of the first subject assuming it can
  % apply to all others.
  opt = getMetaData(BIDS, opt, opt.subjects, suffix);

  fprintf(1, 'WILL WORK ON SUBJECTS\n');
  disp(opt.subjects);

end

function opt = getMetaData(BIDS, opt, subjects, suffix)

  % TODO
  % THIS NEEDS FIXING AS WE MIGHT WANT THE METADATA OF THE SUBJECTS SELECTED
  % RATHER THAN THE FIRST SUBJECT OF THE DATASET

  switch suffix
    case 'bold'
      metadata = bids.query(BIDS, 'metadata', ...
                            'task', opt.taskName, ...
                            'sub', subjects{1}, ...
                            'suffix', suffix, ...
                            'extension', '.nii');

    case 'T1w'
      metadata = bids.query(BIDS, 'metadata', ...
                            'sub', subjects{1}, ...
                            'suffix', suffix);
  end

  if iscell(metadata)
    opt.metadata = metadata{1};
  else
    opt.metadata = metadata;
  end

end
