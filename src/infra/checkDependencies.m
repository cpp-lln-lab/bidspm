function checkDependencies(opt)
  %
  % Checks that that the right dependencies are installeda and
  % loads the spm defaults.
  %
  % USAGE::
  %
  %   checkDependencies()
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  printToScreen('Checking dependencies\n', opt);

  SPM_main = 'SPM12';
  SPM_sub = 7219;

  %% check spm version
  try
    [a, b] = spm('ver');
  catch
    msg = 'Failed to check the SPM version: Are you sure that SPM is in the matlab path?';
    tolerant = false;
    errorHandling(mfilename(), 'noSpm', msg, tolerant, opt.verbosity);
  end

  fprintf(' Using %s %s\n', a, b);

  if ~strcmp(a, SPM_main) || str2num(b) < 7219
    str = sprintf('%s %s %s.\n%s', ...
                  'The current version SPM version is less than', SPM_main, SPM_sub, ...
                  'Update with: spm_update update');
    warning(str); %#ok<*SPWRN>
  end

  spm('defaults', 'fmri');

  printToScreen(' We got all we need. Let''s get to work.\n', opt);

end
