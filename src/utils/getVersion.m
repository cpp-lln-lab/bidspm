function versionNumber = getVersion()
  %
  % Reads the version number of the pipeline from the txt file in the root of the
  % repository.
  %
  % USAGE::
  %
  %   versionNumber = getVersion()
  %
  % :returns: :versionNumber: (string) Use semantic versioning format (like v0.1.0)
  %
  % (C) Copyright 2020 CPP_SPM developers

  try
    versionNumber = fileread(fullfile(fileparts(mfilename('fullpath')), ...
                                      '..', '..', 'version.txt'));
  catch
    versionNumber = 'v1.1.3 ';
  end

  % dirty hack to get rid of line return
  versionNumber = versionNumber(1:end - 1);
end
