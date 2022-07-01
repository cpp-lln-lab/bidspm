function varargout = getInfo(BIDS, subLabel, opt, info, varargin)
  %
  % Wrapper function to fetch specific info in a BIDS structure returned by
  % spm_bids.
  %
  % USAGE::
  %
  %   varargout = getInfo(BIDS, subLabel, opt, info, varargin)
  %
  % If info = ``sessions``, this returns name of the sessions and their number::
  %
  %   [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'sessions')
  %
  % If info = ``runs``, this returns name of the runs and their number for a
  % specified session::
  %
  %   [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'runs', sessionID)
  %
  % If info = ``filename``, this returns the name of the file for a specified
  % session and run::
  %
  %   filenames = getInfo(BIDS, subLabel, opt, 'filename', sessionID, runID, suffix)
  %
  %
  % :param BIDS:            returned by bids.layout when exploring a BIDS data set.
  % :type BIDS:             structure
  %
  % :param subLabel:        label of the subject ; in BIDS lingo that means that for a file name
  %                         ``sub-02_task-foo_bold.nii`` the subLabel will be the string ``02``
  % :type subLabel:         string
  %
  % :param opt:             Used to find the task name and to pass extra ``query``
  %                         options.
  % :type opt:              structure
  %
  % :param info:            ``sessions``, ``runs``, ``filename``.
  % :type info:             string
  %
  % :param sessionLabel:   session label (for `ses-001`, the label will be `001`)
  % :type sessionLabel:    string
  %
  % :param runIdx:          run index label (for `run-001`, the label will be `001`)
  % :type runIdx:           string
  %
  % :param suffix:            datatype (``bold``, ``events``, ``physio``)
  % :type suffix:             string
  %
  % (C) Copyright 2020 CPP_SPM developers

  % TODO make it more flexible to fetch anat, confounds...

  varargout = {}; %#ok<*NASGU>

  switch lower(info)

    case 'sessions'

      if isfield(opt, 'taskName')
        filter = struct('sub',  subLabel, ...
                        'task', {opt.taskName}, ...
                        'modality', 'func');
      else
        filter = struct('sub',  subLabel);
      end
      % update query with pre-specified options
      % overwrite is set to true in this case because we might want to run
      % analysis only on certain sessions
      overwrite = true;
      filter = setFields(filter, opt.query, overwrite);

      sessions = bids.query(BIDS, 'sessions', filter);

      nbSessions = numel(sessions);
      if nbSessions == 0
        nbSessions = 1;
        sessions = {''};
      end

      varargout = {sessions, nbSessions};

    case 'runs'

      session = varargin{1};

      filter = struct('sub',  subLabel, ...
                      'task', {opt.taskName}, ...
                      'ses', session, ...
                      'modality', 'func', ...
                      'suffix', opt.bidsFilterFile.bold.suffix);

      % use the extra query options specified in the options
      filter = setFields(filter, opt.query);
      filter = removeEmptyQueryFields(filter);

      runs = bids.query(BIDS, 'runs', filter);

      nbRuns = numel(runs);

      if isempty(runs)
        nbRuns = 1;
        runs = {''};
      end

      varargout = {runs, nbRuns};

    case {'filename', 'metadata'}

      [session, run, suffix] = deal(varargin{:});

      filter = struct('sub',  subLabel, ...
                      'task', {opt.taskName}, ...
                      'ses', session, ...
                      'run', run, ...
                      'suffix', suffix, ...
                      'extension', {{'.nii', '.nii.gz'}}, ...
                      'prefix', '');

      % use the extra query options specified in the options
      filter = setFields(filter, opt.query);
      filter = removeEmptyQueryFields(filter);

      if strcmpi(info, 'filename')
        filenames = bids.query(BIDS, 'data', filter);

        varargout = {char(filenames)};

      elseif strcmpi(info, 'metadata')
        metadata = bids.query(BIDS, 'metadata', filter);
        varargout = {metadata};
      end

    otherwise
      errorHandling(mfilename(), 'unknownRequest', ...
                    'Not sure what info you want me to get.', ...
                    false, true);

  end

end
