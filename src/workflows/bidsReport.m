function bidsReport(opt)
  %
  % Prints out a human readable description of a BIDS data set for every subject
  % in ``opt.subjects``.
  %
  % The output is a markdown file save in the directory:
  %
  %   ``opt.dir.output, 'reports', ['sub-' subLabel]``
  %
  % USAGE::
  %
  %   opt.dir.input = "path_to_dataset"
  %   bidsReport(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  %

  % (C) Copyright 2020 bidspm developers

  opt.pipeline.type = 'preproc';
  
  if ~opt.boilerplate_only && ...
      isdir(fullfile(opt.dir.output, 'reports'))
      logger('INFO', 'Dataset reports alread exist.', ...
             'options', opt, ...
             'id', mfilename());
      return
  end

  [BIDS, opt] = setUpWorkflow(opt, 'BIDS report');

  bids.diagnostic(BIDS, ...
                  'split_by', {'task'}, ...
                  'output_path', fullfile(opt.dir.output, 'reports'), ...
                  'verbose', false);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    outputDir = fullfile(opt.dir.output, 'reports', ['sub-' subLabel]);

    bids.util.mkdir(outputDir);

    filter = struct('sub', subLabel, 'modality', {opt.query.modality});

    try
      bids.report(BIDS, ...
                  'filter', filter, ...
                  'output_path', outputDir, ...
                  'read_nifti', true, ...
                  'verbose', false);
    catch
      % in case we are dealing with empty files (a la bids-examples, or with
      % datalad datasets symlinks)

      msg = sprintf('Could not read data to write report for dataset:\n%s', BIDS.pth);
      id = 'unspecifiedError';
      logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

      bids.report(BIDS, ...
                  'filter', filter, ...
                  'output_path', outputDir, ...
                  'read_nifti', false, ...
                  'verbose', false);
    end

  end

end
