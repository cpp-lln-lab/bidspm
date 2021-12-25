function unzippedFullpathName = unzipAndReturnsFullpathName(fullpathName, opt)
  %
  % Unzips an image if necessary
  %
  % USAGE::
  %
  %   unzippedFullpathName = unzipAndReturnsFullpathName(fullpathName)
  %
  % :param fullpathName:
  % :type fullpathName: string array
  %
  % :returns: - :unzippedFullpathName: (string)
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  % TODO use argparse
  % TODO add tests

  if nargin < 2
    opt = struct('dryRun', true());
  end

  if isempty(fullpathName)
    msg = sprintf('Provide at least one file.\n');
    errorHandling(mfilename(), 'emptyInput', msg, false, true);
  end

  for iFile = 1:size(fullpathName)

    [directory, filename, ext] = spm_fileparts(fullpathName(iFile, :));

    if strcmp(ext, '.gz') && ~opt.dryRun

      gunzip(fullpathName(iFile, :));
      if ~isOctave()
        delete(fullpathName(iFile, :));
      end

      unzippedFullpathName{iFile, 1} = fullfile(directory, filename);

    else
      unzippedFullpathName{iFile, 1} = fullfile(directory, [filename ext]);

    end

  end

  unzippedFullpathName = char(unzippedFullpathName);

end
