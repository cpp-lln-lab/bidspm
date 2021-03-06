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
  % If info = ``sessions`, this returns name of the sessions and their number::
  %
  %   [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'sessions')  
  %
  % If info = ``runs``, this returns name of the runs and their number for a
  % specified session::
  %
  %   [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'runs', sessionID)
  %
  % If info = ``filename``, this returns the name of the file for a specified
  % session and run::
  %
  %   filenames = getInfo(BIDS, subLabel, opt, 'filename', sessionID, runID, type)
  %
  % :param BIDS:        returned by bids.layout when exploring a BIDS data set.
  % :type BIDS:         structure
  % :param subLabel:       label of the subject ; in BIDS lingo that means that for a file name
  %                     ``sub-02_task-foo_bold.nii`` the subLabel will be the string ``02``
  % :type subLabel:        string  
  % :param opt:         Mostly used to find the task name.
  % :type opt:          structure  
  % :param info:        ``sessions``, ``runs``, ``filename``.
  % :type info:         string  
  % :param sessionLabel:   session label (for `ses-001`, the label will be `001`)
  % :type sessionLabel:    string
  % :param runIdx:       run index label (for `run-001`, the label will be `001`)
  % :type runIdx:        string
  % :param type:        datatype (``bold``, ``events``, ``physio``)
  % :type type:         string
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
