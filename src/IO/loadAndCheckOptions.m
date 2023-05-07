function opt = loadAndCheckOptions(optionJsonFile)
  %
  % Loads the json file provided describing the options of an analysis. It then checks
  % its content and fills any missing fields with the defaults.
  %
  % If no argument is provided, it checks in the current directory for any
  % ``opt_task-*.json`` files and loads the most recent one by name
  % (using the ``date-`` key).
  %
  % USAGE::
  %
  %   opt = loadAndCheckOptions(optionJsonFile)
  %
  % :param optionJsonFile: Fullpath to the json file describing the options of an
  %                        analysis. It can also be an ``opt`` structure
  %                        containing the options.
  % :type optionJsonFile: char
  %
  % :returns: :opt: (structure) Options chosen for the analysis. See ``checkOptions()``.
  %
  % .. TODO
  %
  %    - add test for when the input is a structure.
  %

  % (C) Copyright 2020 bidspm developers

  if nargin < 1 || isempty(optionJsonFile)
    optionJsonFile = spm_select('FPList', ...
                                fullfile(pwd, 'cfg'), ...
                                '^.*\.json$');
  end

  if isstruct(optionJsonFile)

    opt = optionJsonFile;
    opt = checkOptions(opt);

    return
  end

  % finds most recent option file
  if size(optionJsonFile, 1) > 1
    containsDate = cellfun(@any, regexp(cellstr(optionJsonFile), ...
                                        '^.*[0-9]{4}-[0-9]{2}-[0-9]{2}T.*\.json'));
    if any(containsDate)
      optionJsonFile = optionJsonFile(containsDate, :);
      optionJsonFile = sortrows(optionJsonFile);
      optionJsonFile = optionJsonFile(end, :);
    end
  end

  if ischar(optionJsonFile) && size(optionJsonFile, 1) == 1
    if exist(optionJsonFile, 'file')
      msg = sprintf('\nReading option from: %s.', pathToPrint(optionJsonFile));
      opt = spm_jsonread(optionJsonFile);
      opt = checkOptions(opt);
      logger('INFO', msg, 'options', opt, 'filename', mfilename());
    else
      msg = sprintf('the requested file does not exist: %s', optionJsonFile);
      id = 'missingOptionFile';
      logger('ERROR', msg, 'id', id, 'filename', mfilename());
    end
  end

  % temporary hack to fix the way spm_jsonread reads some empty fields
  % REPORT IT TO SPM
  if isfield(opt, 'subjects') && ~iscell(opt.subjects) && isnan(opt.subjects)
    opt.subjects = {[]};
  end

  opt = checkOptions(opt);

end
