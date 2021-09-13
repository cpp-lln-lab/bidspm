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
  SPM_sub = '7487';

  %% check spm version
  try
    [a, b] = spm('ver');
    msg = sprintf(' Using %s %s\n', a, b);
    printToScreen(msg, opt);
    if any(~[strcmp(a, SPM_main) strcmp(b, SPM_sub)])
      msg = sprintf('%s %s %s.\n%s', ...
                    'The current version SPM version is not', SPM_main, SPM_sub, ...
                    'In case of problems (e.g json file related) consider updating.');
      warning(msg); %#ok<*SPWRN>
      tolerant = true;
      errorHandling(mfilename(), 'wrongSpmVersion', msg, tolerant, opt.verbosity);
    end
  catch
    msg = 'Failed to check the SPM version: Are you sure that SPM is in the matlab path?';
    tolerant = false;
    errorHandling(mfilename(), 'noSpm', msg, tolerant, opt.verbosity);
  end

  spm('defaults', 'fmri');

  %% Check the Nifti tools are indeed there.
  nifti_tools_url = ...
      ['https://www.mathworks.com/matlabcentral/fileexchange/' ...
       '8797-tools-for-nifti-and-analyze-image'];

  a = which('load_untouch_nii');
  if isempty(a)
    msg = sprintf('%s \n%s', ...
                  ['Failed to find the Nifti tools: ' ...
                   'Are you sure they in the matlab path?'], ...
                  'You can download them here: %s', nifti_tools_url);
    error(errorStruct);
    tolerant = false;
    errorHandling(mfilename(), 'missingDependency', msg, tolerant, opt.verbosity);
  else
    printToScreen(' Nifti tools detected\n', opt);
  end

  printToScreen(' We got all we need. Let''s get to work.\n', opt);

end
