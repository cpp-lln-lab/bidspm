% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function [grpLvlCon, iStep] = getGrpLevelContrastToCompute(opt)
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
  
  model = spm_jsonread(opt.model.file);

  for iStep = 1:length(model.Steps)
    if strcmp(model.Steps{iStep}.Level, 'dataset')
      grpLvlCon = model.Steps{iStep}.AutoContrasts;
      break
    end
  end

end
