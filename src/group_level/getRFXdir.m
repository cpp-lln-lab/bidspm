% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function rfxDir = getRFXdir(opt, funcFWHM, conFWHM, contrastName)
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
