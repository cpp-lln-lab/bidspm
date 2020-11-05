% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function files = validationInputFile(dir, fileName, prefix)
  % file = validationInputFile(dir, fileName, prefix)
  %
  % Checks if files exist. A prefix can be added. The prefix allows for the
  % use of regular expression.
  %
  % TPMs = validationInputFile(anatDataDir, anatImage, 'c[12]');
  %
  % If the filet(s) exist(s), it returns a char array containing list of fullpath.

  if nargin < 3
    prefix = '';
  end

  files = spm_select('FPList', dir, ['^' prefix fileName '$']);

  if isempty(files)

    errorStruct.identifier = 'validationInputFile:nonExistentFile';
    errorStruct.message = sprintf( ...
                                  'This file does not exist: %s', ...
                                  fullfile(dir, [prefix fileName '[.gz]']));
    error(errorStruct);

  end

end
