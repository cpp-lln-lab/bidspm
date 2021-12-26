function rfxDir = getRFXdir(opt)
  %
  % Sets the name the group level analysis directory and creates it if it does not exist
  %
  % USAGE::
  %
  %   rfxDir = getRFXdir(opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % :returns: :rfxDir: (string) Fullpath of the group level directory
  %
  % (C) Copyright 2019 CPP_SPM developers

  opt.space = 'MNI';

  glmDirName = createGlmDirName(opt);

  glmDirName = [glmDirName, '_conFWHM-', num2str(opt.fwhm.contrast)];

  model = spm_jsonread(opt.model.file);
  if ~isempty(model.Name) && ~strcmpi(model.Name, strjoin(opt.taskName, ' '))
    glmDirName = [glmDirName, '_desc-', bids.internal.camel_case(model.Name)];
  end

  rfxDir = fullfile( ...
                    opt.dir.stats, ...
                    'derivatives', ...
                    'cpp_spm-groupStats', ...
                    glmDirName);

  spm_mkdir(rfxDir);

end
