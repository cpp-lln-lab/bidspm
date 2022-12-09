function unzippedFullpathName = unzipAndReturnsFullpathName(fullpathName, opt)
  %
  % Unzips a file if necessary
  %
  % USAGE::
  %
  %   unzippedFullpathName = unzipAndReturnsFullpathName(fullpathName)
  %
  % :param fullpathName:
  % :type fullpathName: char array
  %
  % :returns: - :unzippedFullpathName: (string)
  %
  %

  % (C) Copyright 2020 bidspm developers

  % TODO use argparse
  % TODO add tests

  if nargin < 2
    opt = struct('dryRun', true());
  end

  if isempty(fullpathName)
    msg = sprintf('Provide at least one file.\n');
    id = 'emptyInput';
    logger('ERROR', msg, 'id', id, 'filename', mfilename);
  end

  if ~iscell(fullpathName)
    fullpathName = cellstr(fullpathName);
  end

  for iFile = 1:size(fullpathName, 1)

    [directory, filename, ext] = spm_fileparts(fullpathName{iFile});

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
