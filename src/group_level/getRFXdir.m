function rfxDir = getRFXdir(opt, funcFWHM, conFWHM)
  %
  % Sets the name the group level analysis directory and creates it if it does not exist
  %
  % USAGE::
  %
  %   rfxDir = getRFXdir(opt, funcFWHM, conFWHM, contrastName)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param funcFWHM: How much smoothing was applied to the functional
  %                  data in the preprocessing.
  % :type funcFWHM: scalar
  % :param conFWHM: How much smoothing will be applied to the contrast
  %                 images.
  % :type conFWHM: scalar
  % :param contrastName:
  % :type contrastName: string
  %
  % :returns: :rfxDir: (string) Fullpath of the group level directory
  %
  % (C) Copyright 2019 CPP_SPM developers

  opt.space = 'MNI';

  glmDirName = createGlmDirName(opt, funcFWHM);

  glmDirName = [glmDirName, '_conFWHM-', num2str(conFWHM)];

  model = spm_jsonread(opt.model.file);
  if ~isempty(model.Name) && ~strcmpi(model.Name, opt.taskName)
    glmDirName = [glmDirName, '_desc-', bids.internal.camel_case(model.Name)];
  end

  rfxDir = fullfile( ...
                    opt.dir.stats, ...
                    'group', ...
                    glmDirName);

  spm_mkdir(rfxDir);

end
