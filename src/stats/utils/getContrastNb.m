function contrastNb = getContrastNb(result, opt, SPM)
  %
  % Identify the contrast nb actually has the name the user asked
  %
  % The search is regex based and any string (like 'foo') will be by default
  % regexified (into '^foo$').
  %
  % USAGE::
  %
  %     contrastNb = getContrastNb(result, opt, SPM)
  %
  %
  % :param SPM: content of SPM.mat file
  % :type  SPM: structure or path
  %
  % :param result: structure with at least a ``name`` field
  %                with a chat with the name of the contrast of interest
  % :type  result: struct
  %
  % :param opt: Options chosen.
  % :type  opt:  structure
  %
  %
  % See also: printAvailableContrasts, getContrastNb

  % (C) Copyright 2019 bidspm developers

  contrastNb = [];

  if ~isfield(result, 'name') || ...
      isempty(result.name) || ...
      (iscell(result.name) && all(cellfun('isempty', result.name))) || ...
      strcmp(result.name, '^$')

    printAvailableContrasts(SPM, opt);

    msg = 'No contrast name specified';
    id = 'missingContrastName';
    logger('WARNING', msg, 'id', id, 'filename', mfilename());

    return

  end

  result.name = regexify(result.name);

  contrastNb = regexp({SPM.xCon.name}', result.name, 'match');

  contrastNb = find(~cellfun('isempty', contrastNb));

  if isempty(contrastNb)

    printAvailableContrasts(SPM, opt);

    msg = sprintf('\nThis SPM file\n%s\n does not contain a contrast named:\n "%s"', ...
                  fullfile(result.dir, 'SPM.mat'), ...
                  result.name(2:end - 1));
    id = 'noMatchingContrastName';
    logger('WARNING', msg, 'id', id, 'filename', mfilename());

    contrastNb = [];

    return

  end

end
