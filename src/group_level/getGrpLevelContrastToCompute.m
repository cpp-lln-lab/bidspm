% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function [grpLvlCon, iStep] = getGrpLevelContrastToCompute(opt)

  model = spm_jsonread(opt.model.file);

  for iStep = 1:length(model.Steps)
    if strcmp(model.Steps{iStep}.Level, 'dataset')
      grpLvlCon = model.Steps{iStep}.AutoContrasts;
      break
    end
  end

end
