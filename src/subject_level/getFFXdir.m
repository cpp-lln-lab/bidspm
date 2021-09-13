function ffxDir = getFFXdir(subLabel, opt)
  %
  % Sets the name the FFX directory and creates it if it does not exist
  %
  % USAGE::
  %
  %   ffxDir = getFFXdir(subLabel, funcFWFM, opt)
  %
  % :param subLabel:
  % :type subLabel: string
  % :param opt:
  % :param opt: structure
  %
  % :returns: - :ffxDir: (string)
  %
  % (C) Copyright 2019 CPP_SPM developers

  glmDirName = createGlmDirName(opt);

  model = spm_jsonread(opt.model.file);
  if ~isempty(model.Name) && ~strcmpi(model.Name, opt.taskName)
    glmDirName = [glmDirName, '_desc-', bids.internal.camel_case(model.Name)];
  end

  ffxDir = fullfile(opt.dir.stats, ...
                    ['sub-', subLabel], ...
                    'stats', ...
                    glmDirName);

  if opt.glm.roibased.do
    ffxDir = [ffxDir '_roi'];
  end

  spm_mkdir(ffxDir);

end
