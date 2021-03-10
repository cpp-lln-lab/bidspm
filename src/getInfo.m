% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function varargout = getInfo(BIDS, subLabel, opt, info, varargin)
  %
  % Wrapper function to fetch specific info in a BIDS structure returned by
  % spm_bids.
  %
  % USAGE::
  %
  %   varargout = getInfo(BIDS, subLabel, opt, info, varargin)
  %
  % :param BIDS: (structure) returned by bids.query when exploring a BIDS data set.
  % :param subLabel: ID of the subject
  % :param opt: (structure) Mostly used to find the task name.
  % :param info: (strint) ``sessions``, ``runs``, ``filename``.
  % :param varargin: see below
  %
  % - subLabel - ID of the subject ; in BIDS lingo that means that for a file name
  %   ``sub-02_task-foo_bold.nii`` the subLabel will be the string ``02``
  % - session - ID of the session of interes ; in BIDS lingo that means that for a file name
  %   ``sub-02_ses-pretest_task-foo_bold.nii`` the sesssion will be the string
  %   ``pretest``
  % - run: ID of the run of interest
  % - type - string ; modality type to look for. For example: ``bold``, ``events``,
  %   ``stim``, ``physio``
  %
  % for a given BIDS data set, subject identity, and info type,
  %
  % if info = Sessions, this returns name of the sessions and their number
  %
  % if info = Runs, this returns name of the runs and their number for an specified session.
  %
  % if info = Filename, this returns the name of the file for an specified
  % session and run.
  %

  varargout = {}; %#ok<*NASGU>

  switch lower(info)

    case 'sessions'

      sessions = bids.query(BIDS, 'sessions', ...
                            'sub', subLabel, ...
                            'task', opt.taskName);
      nbSessions = size(sessions, 2);
      if nbSessions == 0
        nbSessions = 1;
        sessions = {''};
      end

      varargout = {sessions, nbSessions};

    case 'runs'

      session = varargin{1};

      runs = bids.query(BIDS, 'runs', ...
                        'sub', subLabel, ...
                        'task', opt.taskName, ...
                        'ses', session, ...
                        'type', 'bold');
      nbRuns = size(runs, 2);     % Get the number of runs

      if nbRuns == 0
        nbRuns = 1;
        runs = {''};
      end

      varargout = {runs, nbRuns};

    case 'filename'

      [session, run, type] = deal(varargin{:});

      varargout = bids.query(BIDS, 'data', ...
                             'sub', subLabel, ...
                             'run', run, ...
                             'ses', session, ...
                             'task', opt.taskName, ...
                             'type', type);

    otherwise
      error('Not sure what info you want me to get.');

  end

end
