function filename = getConfoundsRegressorFilename(BIDS, opt, subLabel, session, run)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   realignParamFile = getRealignParamFile(BIDS, subLabel, session, run, opt)
  %
  % :param BIDS:        returned by bids.layout when exploring a BIDS data set.
  % :type BIDS:         structure
  % :param subID:       label of the subject ; in BIDS lingo that means that for a file name
  %                     ``sub-02_task-foo_bold.nii`` the subID will be the string ``02``
  % :type subID:        string
  % :param sessionID:   session label (for `ses-001`, the label will be `001`)
  % :type sessionID:    string
  % :param runID:       run index label (for `run-001`, the label will be `001`)
  % :type runID:        string
  % :param opt:         Mostly used to find the task name.
  % :type opt:          structure
  %
  % :returns: - :filename: (string)
  %
  % (C) Copyright 2021 CPP_SPM developers

  filename = bids.query(BIDS, 'data', ...
                        'prefix', '', ...
                        'sub', subLabel, ...
                        'ses', session, ...
                        'run', run, ...
                        'desc', 'confounds', ...
                        'suffix', 'regressors', ...
                        'extension', '.tsv', ...
                        'task', opt.taskName);

  if numel(filename) > 1
    error('too many files');
  end
  filename = filename{1};

end
