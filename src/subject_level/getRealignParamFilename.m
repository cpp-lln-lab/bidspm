function realignParamFile = getRealignParamFilename(BIDS, subLabel, session, run, opt)
  %
  % Gets the realignement parameter file produced by SPM (rp_*.txt) for a given
  % subject, session, run
  %
  % USAGE::
  %
  %   realignParamFile = getRealignParamFile(BIDS, subLabel, session, run, opt)
  %
  % :param BIDS:        returned by bids.layout when exploring a BIDS data set.
  % :type BIDS:         structure
  % :param subLabel:       label of the subject ; in BIDS lingo that means that for a file name
  %                     ``sub-02_task-foo_bold.nii`` the subLabel will be the string ``02``
  % :type subLabel:        string
  % :param session:   session label (for `ses-001`, the label will be `001`)
  % :type session:    string
  % :param run:       run index label (for `run-001`, the label will be `001`)
  % :type run:        string
  % :param opt:         Mostly used to find the task name.
  % :type opt:          structure
  %
  % :returns: - :realignParamFile: (string)
  %
  % (C) Copyright 2020 CPP_SPM developers

  realignParamFile = bids.query(BIDS, 'data', ...
                                'prefix', 'rp_', ...
                                'sub', subLabel, ...
                                'ses', session, ...
                                'run', run, ...
                                'extension', '.txt', ...
                                'task', opt.taskName);

  if numel(realignParamFile) > 1
    error('too many files');
  end
  realignParamFile = realignParamFile{1};

end
