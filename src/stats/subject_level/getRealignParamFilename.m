function realignParamFile = getRealignParamFilename(BIDS, subLabel, session, run, opt)
  %
  % Gets the realignement parameter file produced by SPM (rp_*.txt) for a given
  % subject, session, run
  %
  % USAGE::
  %
  %   realignParamFile = getRealignParamFile(BIDS, subLabel, session, run, opt)
  %
  % :param BIDS:       dataset layout.
  %                    See also: bids.layout, getData.
  % :type  BIDS:       structure
  %
  % :param subLabel:   label of the subject ; in BIDS lingo that means that for a file name
  %                    ``sub-02_task-foo_bold.nii`` the subLabel will be the string ``02``
  % :type  subLabel:   char
  %
  % :param session:   session label (for `ses-001`, the label will be `001`)
  % :type  session:   string
  %
  % :param run:       run index label (for `run-001`, the label will be `001`)
  % :type  run:       string
  %
  % :param opt:       Options chosen for the analysis.
  %                   See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type  opt:       structure
  %
  % :returns: - :realignParamFile: (string)
  %

  % (C) Copyright 2020 bidspm developers

  filter = struct('prefix', 'rp_', ...
                  'sub', subLabel, ...
                  'ses', session, ...
                  'run', run, ...
                  'task', opt.taskName, ...
                  'extension', '.txt');

  realignParamFile = bids.query(BIDS, 'data', filter);

  if numel(realignParamFile) > 1
    msg = ['Too many realignment parameter files found for', createUnorderedList(filter)];
    logger('ERROR', msg, 'filename', mfilename, 'id', 'tooManyFiles');
  end
  realignParamFile = realignParamFile{1};

end
