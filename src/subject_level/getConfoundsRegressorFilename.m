function filename = getConfoundsRegressorFilename(BIDS, opt, subLabel, session, run)
  %
  % Gets the ``_confounds.tsv`` for a given subject, session, run
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
  % (C) Copyright 2021 CPP_SPM developers

  filter = fileFilterForBold(opt, subLabel, 'confounds');
  filter.ses = session;
  filter.run = run;
  filename = bids.query(BIDS, 'data', filter);

  if numel(filename) > 1
    disp(filename);
    errorHandling(mfilename(), 'tooManyFiles', 'This should only get one file.', false, true);
  elseif isempty(filename)
    msg = sprintf('No TSV file found in:\n\t%s\nfor query:%s\n', ...
                  BIDS.pth, ...
                  createUnorderedList(opt.query));
    errorHandling(mfilename(), 'noFileFound', msg, false, true);
  end

  filename = filename{1};

end
