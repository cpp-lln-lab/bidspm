function reportBIDS(opt)
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
  %   reportBIDS(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  %
  % (C) Copyright 2020 bidspm developers

  opt.pipeline.type = 'preproc';

  [BIDS, opt] = setUpWorkflow(opt, 'BIDS report');

  bids.diagnostic(BIDS, ...
                  'split_by', {'task'}, ...
                  'output_path', fullfile(opt.dir.output, 'reports'));

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
                  'verbose', opt.verbosity > 1);
    catch
      % in case we are dealing with empty files (a la bids-examples, or with
      % datalad datasets symlinks)

      msg = sprintf('Could not read data to write report for dataset:\n%s\n\n', BIDS.pth);
      errorHandling(mfilename(), 'unspecifiedError', msg, true, opt.verbosity);

      bids.report(BIDS, ...
                  'filter', filter, ...
                  'output_path', outputDir, ...
                  'read_nifti', false, ...
                  'verbose', opt.verbosity);
    end

  end

end
