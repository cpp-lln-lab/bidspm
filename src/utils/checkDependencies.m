function checkDependencies()
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

  fprintf('Checking dependencies\n');

  SPM_main = 'SPM12';
  SPM_sub = '7487';

  %% check spm version
  try
    [a, b] = spm('ver');
  catch
    error('Failed to check the SPM version: Are you sure that SPM is in the matlab path?');
  end

  fprintf(' Using %s %s\n', a, b);

  if ~strcmp(a, SPM_main) || str2num(SPM_sub) < 7219
    str = sprintf('%s %s %s.\n%s', ...
                  'The current version SPM version is less than', SPM_main, SPM_sub, ...
                  'Update with: spm_update update');
    warning(str); %#ok<*SPWRN>
  end

  spm('defaults', 'fmri');

  %% Check the Nifti tools are indeed there.
  nifti_tools_url = ...
      ['https://www.mathworks.com/matlabcentral/fileexchange/' ...
       '8797-tools-for-nifti-and-analyze-image'];

  a = which('load_untouch_nii');
  if isempty(a)
    errorStruct.identifier = 'checkDependencies:missingDependency';
    errorStruct.message = sprintf('%s \n%s', ...
                                  ['Failed to find the Nifti tools: ' ...
                                   'Are you sure they in the matlab path?'], ...
                                  'You can download them here: %s', nifti_tools_url);
    error(errorStruct);
  else
    fprintf(' Nifti tools detected\n');
  end

  fprintf(' We got all we need. Let''s get to work.\n');

end
