function versionNumber = getVersion()
  %
  % Reads the version number of the pipeline from the txt file in the root of the
  % repository.
  %
  % USAGE::
  %
  %   versionNumber = getVersion()
  %
  % :return: versionNumber: (string) Use semantic versioning format (like v0.1.0)
  %

  % (C) Copyright 2020 bidspm developers

  try
    versionNumber = fileread(fullfile(fileparts(mfilename('fullpath')), ...
                                      '..', '..', 'version.txt'));
  catch

    versionNumber = 'v1.1.4dev ';

  end

  % dirty hack to get rid of line return
  versionNumber = versionNumber(1:end - 1);
end
