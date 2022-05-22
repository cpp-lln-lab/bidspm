function glmDirName = createGlmDirName(opt)
  %
  % USAGE::
  %
  %   glmDirName = createGlmDirName(opt)
  %
  % (C) Copyright 2021 CPP_SPM developers

  % TODO use tasks defined in model for glm dir

  if ~ischar(opt.space) && numel(opt.space) > 1
    printToScreen(['Requested spaces: ' strjoin(opt.space) '\n'], opt);
    msg = sprintf('Please specify only a single space');
    id = 'tooManyMRISpaces';
    errorHandling(mfilename(), id, msg, false, opt.verbosity);
  end

  spec = struct('entities', struct('task', strjoin(opt.taskName, ''), ...
                                   'space', char(opt.space), ...
                                   'FWHM', num2str(opt.fwhm.func)));
  bf = bids.File(spec);

  glmDirName = bf.filename;

end
