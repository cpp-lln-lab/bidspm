% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function files = validationInputFile(dir, fileNamePattern, prefix)
  %
  % Looks for file name pattern in a given directory and returns all the files
  % that match that pattern but throws an error if it cannot find any.
  %
  % A prefix can be added to the filename.
  %
  % This function is mostly used that a file exists so
  % that an error is thrown early when building a SPM job rather than at run
  % time.
  %
  % USAGE::
  %
  %   files = validationInputFile(dir, fileName[, prefix])
  %
  % :param dir: Directory where the search will be conducted.
  % :type dir: string
  % :param fileName: file name pattern. Can be a regular expression except for
  %                  the starting ``^`` and ending ``$``. For example:
  %                  ``'sub-.*_ses-.*_task-.*_bold.nii'``.
  % :type fileName: string
  % :param prefix: prefix to be added to the filename pattern. This can also be
  %                a regular expression (ish). For example ,f looking for the files that
  %                start with ``c1`` or ``c2`` or ``c3``, the prefix can be
  %                ``c[123]``.
  % :type prefix: string
  %
  % :returns:
  %
  %           :files: (string array) returns the fullpath file list of all the
  %                   files matching the required pattern.
  %
  %
  % See also: ``spm_select``.
  %
  %
  % Example:
  % %
  % % tissueProbaMaps = validationInputFile(anatDataDir, anatImage, 'c[12]');
  %
  %

  % try to guess directory in case a fullpath filename was given
  if isempty(dir)
    [dir, fileNamePattern, ext] = spm_fileparts(fileNamePattern);
    fileNamePattern = [fileNamePattern, ext];
  end

  if nargin < 3
    prefix = '';
  end

  files = spm_select('FPList', dir, ['^' prefix fileNamePattern '$']);

  if isempty(files)

    errorStruct.identifier = 'validationInputFile:nonExistentFile';
    errorStruct.message = sprintf( ...
                                  'This file does not exist: %s', ...
                                  fullfile(dir, [prefix fileNamePattern '[.gz]']));
    error(errorStruct);

  end

end
