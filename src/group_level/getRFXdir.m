function rfxDir = getRFXdir(opt, nodeName, contrastName)
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
  % Typical output:
  %
  % - ``opt.dir.derivatives/cpp_spm-stats/derivatives/cpp_spm-groupStats/cpp_spm-stats``
  %
  % .. code-block:: matlab
  %
  %   ['task-',     model.Input.task, ...
  %    '_space-'    model.Input.space, ...
  %    '_FWHM-',    num2str(opt.fwhm.func), ...
  %    '_conFWHM-', opt.fwhm.contrast, ...
  %    'desc-', model.Input.Nodes(dataset_level).Name, ...             % optional
  %    'contrast-', model.Input.Nodes(dataset_level).Contrast(i).Name  % if ~= from "dataset_level"
  %    ]
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 2
    nodeName = '';
  end

  if nargin < 3
    contrastName = '';
  end

  glmDirName = createGlmDirName(opt);

  glmDirName = [glmDirName, '_conFWHM-', num2str(opt.fwhm.contrast)];

  if ~isempty(nodeName) && ~strcmpi(nodeName, 'dataset_level')
    glmDirName = [glmDirName, '_desc-', bids.internal.camel_case(nodeName)];
  end

  if ~isempty(contrastName) && ~strcmpi(contrastName, 'dataset_level')
    glmDirName = [glmDirName, '_contrast-', bids.internal.camel_case(contrastName)];
  end

  rfxDir = fullfile(opt.dir.stats, ...
                    'derivatives', ...
                    'cpp_spm-groupStats', ...
                    glmDirName);

  spm_mkdir(rfxDir);

end
