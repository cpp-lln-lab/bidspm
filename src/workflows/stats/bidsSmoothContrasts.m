function matlabbatch = bidsSmoothContrasts(varargin)
  %
  % - smooths all contrast images created at the subject level
  %
  %
  % USAGE::
  %
  %  bidsSmoothContrasts(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  %
  %

  % (C) Copyright 2023 bidspm developers

  args = inputParser;

  args.addRequired('opt', @isstruct);

  args.parse(varargin{:});

  opt =  args.Results.opt;

  matlabbatch = {};
  if opt.fwhm.contrast <= 0
    return
  end

  opt.pipeline.type = 'stats';

  description = 'smooth contrasts';

  opt.dir.output = opt.dir.stats;

  % To speed up group level we skip indexing data
  indexData = false;
  [~, opt] = setUpWorkflow(opt, description, [], indexData);

  checks(opt);

  matlabbatch = setBatchSmoothConImages(matlabbatch, opt);
  saveAndRunWorkflow(matlabbatch, ...
                     ['smooth_con_FWHM-', num2str(opt.fwhm.contrast), ...
                      '_task-', strjoin(opt.taskName, '')], ...
                     opt);

  cleanUpWorkflow(opt);

end

function checks(opt)
  if numel(opt.space) > 1
    disp(opt.space);
    msg = sprintf('GLMs can only be run in one space at a time.\n');
    id = 'tooManySpaces';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end
end
