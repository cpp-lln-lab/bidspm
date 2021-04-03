% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function ffxDir = getFFXdir(subLabel, funcFWFM, opt)
  %
  % Sets the name the FFX directory and creates it if it does not exist
  %
  % USAGE::
  %
  %   ffxDir = getFFXdir(subLabel, funcFWFM, opt)
  %
  % :param subLabel:
  % :type subLabel: string
  % :param funcFWFM:
  % :type funcFWFM: scalar
  % :param opt:
  % :param opt: structure
  %
  % :returns: - :ffxDir: (string)
  %

  glmDirName = createGlmDirName(opt, funcFWFM);

  model = spm_jsonread(opt.model.file);
  if ~isempty(model.Name) && ~strcmpi(model.Name, opt.taskName)
    glmDirName = [glmDirName, '_desc-', convertToValidCamelCase(model.Name)];
  end

  ffxDir = fullfile(opt.dir.stats, ...
                    ['sub-', subLabel], ...
                    'stats', ...
                    glmDirName);

  spm_mkdir(ffxDir);

end
