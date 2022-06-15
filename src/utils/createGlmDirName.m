function glmDirName = createGlmDirName(opt)
  %
  % USAGE::
  %
  %   glmDirName = createGlmDirName(opt)
  %
  % (C) Copyright 2021 CPP_SPM developers

  % TODO use tasks defined in model for glm dir

  filter = fileFilterForBold(opt);

  if ~ischar(filter.space) && numel(filter.space) > 1
    printToScreen(['Requested spaces: ' strjoin(filter.space) '\n'], opt);
    msg = sprintf('Please specify only a single space');
    id = 'tooManyMRISpaces';
    errorHandling(mfilename(), id, msg, false, opt.verbosity);
  end

  % make sure we use BIDS entities requested in stats model to folder name
  boldRawEntities = {'acq', 'ce', 'rec', 'dir', 'echo', 'part'};

  spec = struct('entities', struct('task', filter.task, ...
                                   'acq', '', ...
                                   'ce', '', ...
                                   'rec', '', ...
                                   'dir', '', ...
                                   'echo', '', ...
                                   'part', '', ...
                                   'space', char(filter.space), ...
                                   'FWHM', num2str(opt.fwhm.func)));

  isPresent = find(ismember(boldRawEntities, fieldnames(filter)));
  if ~isempty(isPresent)
    for i = 1:numel(isPresent)
      thisEntity = boldRawEntities{isPresent(i)};
      spec.entities.(thisEntity) = strjoin(filter.(thisEntity), '');
    end
  end

  % Concatenate any eventual cells
  fields = fieldnames(spec.entities);
  for i = 1:numel(fields)
    if iscell(spec.entities.(fields{i}))
      spec.entities.(fields{i}) = strjoin(spec.entities.(fields{i}), '');
    end
  end

  bf = bids.File(spec);

  glmDirName = bf.filename;

end
