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
  % :param subLabel:       label of the subject ; in BIDS lingo that means that for a file name
  %                     ``sub-02_task-foo_bold.nii`` the subLabel will be the string ``02``
  % :type subLabel:        string
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

  % task details are passed in opt.query
  query = struct( ...
                 'sub',  subLabel, ...
                 'ses', session, ...
                 'run', run, ...
                 'desc', 'confounds', ...
                 'suffix', 'regressors', ...
                 'extension', '.tsv');

  % use the extra query options specified in the options
  query = setFields(query, opt.query);
  query = removeEmptyQueryFields(query);

  filename = bids.query(BIDS, 'data', query);

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
