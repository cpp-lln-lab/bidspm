% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

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

  rfxDir = fullfile( ...
                    opt.derivativesDir, ...
                    'group', ...
                    ['rfx_task-', opt.taskName], ...
                    ['rfx_funcFWHM-', num2str(funcFWHM), '_conFWHM-', num2str(conFWHM)]);

  if ~exist(rfxDir, 'dir')
    mkdir(rfxDir);
  end

end
