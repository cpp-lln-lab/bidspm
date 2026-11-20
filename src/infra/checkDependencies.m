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

  % (C) Copyright 2019 bidspm developers

  logger('INFO', 'Checking dependencies', 'options', opt, 'filename', mfilename());

  SPM_main = 'SPM12';
  SPM_sub = 7219;

  %% check spm version
  try
    [a, b] = spm('ver');
  catch
    msg = 'Failed to check the SPM version: Are you sure that SPM is in the matlab path?';
    id = 'noSpm';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

  msg = sprintf(' Using %s %s', a, b);
  logger('INFO', msg, 'options', opt, 'filename', mfilename());

  % name is 'SPM12' for SPM12, 'SPM25', 'SPM26'... for newer releases
  spmMajor = sscanf(a, 'SPM%d');
  if isempty(spmMajor) || spmMajor < 12 || (spmMajor == 12 && str2double(b) < SPM_sub)
    str = sprintf('%s %s %i.\n%s', ...
                  'The current version SPM version is less than', SPM_main, SPM_sub, ...
                  'Update with: spm_update update');
    warning(str); %#ok<*SPWRN>
  end

  spm('defaults', 'fmri');
  spm_jobman('initcfg');

end
