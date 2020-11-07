% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

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
  
  try
    versionNumber = fileread(fullfile(fileparts(mfilename('fullpath')), ...
                                      '..', '..', 'version.txt'));
  catch
    versionNumber = 'v0.1.0';
  end
end
