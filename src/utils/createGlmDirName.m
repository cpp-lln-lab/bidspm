function glmDirName = createGlmDirName(opt, FWHM)
  %
  % (C) Copyright 2021 CPP_SPM developers

  glmDirName = ['task-', opt.taskName, ...
                '_space-' opt.space, ...
                '_FWHM-', num2str(FWHM)];

end
