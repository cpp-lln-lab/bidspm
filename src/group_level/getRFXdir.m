% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function rfxDir = getRFXdir(opt, funcFWHM, conFWHM, contrastName)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % rfxDir = getRFXdir(opt, funcFWHM, conFWHM, iStep, iCon)
  %
  % sets the name the RFX directory and creates it if it does not exist
  %

  rfxDir = fullfile( ...
                    opt.derivativesDir, ...
                    'group', ...
                    ['rfx_task-', opt.taskName], ...
                    ['rfx_funcFWHM-', num2str(funcFWHM), '_conFWHM-', num2str(conFWHM)], ...
                    contrastName);

  if ~exist(rfxDir, 'dir')
    mkdir(rfxDir);
  end

end
