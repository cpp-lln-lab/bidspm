function glmDirName = createGlmDirName(opt)
  %
  % USAGE::
  %
  %   glmDirName = createGlmDirName(opt)
  %
  % (C) Copyright 2021 CPP_SPM developers

  if ~ischar(opt.space) && numel(opt.space) > 1
    printToScreen(['Requested spaces: ' strjoin(opt.space) '\n'], opt);
    msg = sprintf('Please specify only a single space');
    id = 'tooManyMRISpaces';
    errorHandling(mfilename(), id, msg, false, opt.verbosity);
  end

  glmDirName = ['task-', strjoin(opt.taskName, ''), ...
                '_space-' char(opt.space), ...
                '_FWHM-', num2str(opt.fwhm.func)];

end
