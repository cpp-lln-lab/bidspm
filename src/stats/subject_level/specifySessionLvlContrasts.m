function [contrasts, counter] = specifySessionLvlContrasts(contrasts, node, counter, SPM)
  %
  %
  %
  % USAGE::
  %
  %   [contrasts, counter] = specifySessionLvlContrasts(contrasts, node, counter, SPM)
  %
  % :param contrasts:
  % :type  contrasts: struct
  %
  % :param node:
  % :type  node:
  %
  % :param counter:
  % :type  counter: integer
  %
  % :param SPM:
  % :type  SPM: struct
  %
  %
  % See also: specifyContrasts
  %

  % (C) Copyright 2023 bidspm developers

  if ~isfield(node, 'Contrasts')
    return
  end

  % then the contrasts that involve contrasting conditions
  % amongst themselves or something inferior to baseline
  for iCon = 1:length(node.Contrasts)

    this_contrast = checkContrast(node, iCon);

    if isempty(this_contrast) || strcmp(this_contrast.Test, 'pass')
      continue
    end

  end

end
