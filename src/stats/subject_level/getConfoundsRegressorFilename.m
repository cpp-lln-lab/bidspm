function filenames = getConfoundsRegressorFilename(BIDS, opt, subLabel, session, run)
  %
  % Gets the potential confounds files for a given subject, session, run
  %
  % USAGE::
  %
  %   realignParamFile = getRealignParamFile(BIDS, subLabel, session, run, opt)
  %
  % :param BIDS:       dataset layout.
  %                    See also: bids.layout, getData.
  % :type BIDS:        structure
  %
  % :param subLabel:  label of the subject ; in BIDS lingo that means that for a file name
  %                   ``sub-02_task-foo_bold.nii`` the subLabel will be the string ``02``
  % :type subLabel:   char
  %
  % :param session:   session label (for `ses-001`, the label will be `001`)
  % :type session:    char
  %
  % :param run:       run index label (for `run-001`, the label will be `001`)
  % :type run:        char
  %
  % :param opt:       Options chosen for the analysis.
  %                   See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt:        structure
  %
  %
  % :returns: - :filename: (string)
  %

  % (C) Copyright 2021 bidspm developers

  filter = fileFilterForBold(opt, subLabel, 'confounds');
  filter.ses = session;
  filter.run = run;
  filenames = bids.query(BIDS, 'data', filter);

  if numel(filenames) > 1
    msg = ['Found several confounds files:' createUnorderedList(filenames)];
    id = 'tooManyFiles';
    logger('WARNING', msg, 'id', id, 'filename', mfilename()(), 'options', opt);

  elseif isempty(filenames)
    msg = sprintf('No TSV file found in:\n\t%s\nfor query:%s\n', ...
                  BIDS.pth, ...
                  createUnorderedList(opt.query));
    id = 'noFileFound';
    logger('WARNING', msg, 'id', id, 'filename', mfilename()(), 'options', opt);

  end

end
