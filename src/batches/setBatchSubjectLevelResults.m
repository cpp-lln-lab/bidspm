function matlabbatch = setBatchSubjectLevelResults(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelResults(matlabbatch, opt, subLabel, funcFWHM, iNode, iCon)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param opt:
  % :type opt: structure
  % :param subLabel:
  % :type subLabel: string
  % :param iNode:
  % :type iNode: positive integer
  % :param iCon:
  % :type iCon: positive integer
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2019 CPP_SPM developers

  [matlabbatch, opt, subLabel, iNode, iCon] = deal(varargin{:});

  result.Contrasts = opt.result.Nodes(iNode).Contrasts(iCon);
  result.dir = getFFXdir(subLabel, opt);

  result.contrastNb = getContrastNb(result, opt);
  if isempty(result.contrastNb)
    msg = sprintf('Skipping contrast named %s', result.Contrasts.Name);
    errorHandling(mfilename(), 'skippingContrastResults', msg, true, true);
    return
  end

  if isfield(opt.result.Nodes(iNode), 'Output')
    result.Output =  opt.result.Nodes(iNode).Output;
  end

  result.space = opt.space;

  result.label = subLabel;

  result.nbSubj = 1;

  result.outputNameStructure = struct( ...
                                      'suffix', 'spmT', ...
                                      'ext', '.nii', ...
                                      'use_schema', 'false', ...
                                      'entities', struct('sub', '', ...
                                                         'task', strjoin(opt.taskName, ''), ...
                                                         'space', result.space, ...
                                                         'desc', '', ...
                                                         'label', sprintf('%04.0f', ...
                                                                          result.contrastNb), ...
                                                         'p', '', ...
                                                         'k', '', ...
                                                         'MC', ''));

  matlabbatch = setBatchResults(matlabbatch, result);

end

function contrastNb = getContrastNb(result, opt)
  %
  % identify which contrast nb actually has the name the user asked
  %

  load(fullfile(result.dir, 'SPM.mat'));

  if isempty(result.Contrasts.Name)

    printAvailableContrasts(SPM, opt);

    msg = 'No contrast name specified';

    errorHandling(mfilename(), 'missingContrastName', msg, false, true);

  end

  contrastNb = find(strcmp({SPM.xCon.name}', result.Contrasts.Name));

  if isempty(contrastNb)

    printAvailableContrasts(SPM, opt);

    msg = sprintf( ...
                  '\nThis SPM file %s does not contain a contrast named %s', ...
                  fullfile(result.dir, 'SPM.mat'), ...
                  result.Contrasts.Name);

    errorHandling(mfilename(), 'noMatchingContrastName', msg, true, true);

  end

end

function printAvailableContrasts(SPM, opt)
  printToScreen('List of contrast in this SPM file\n', opt);
  printToScreen(strjoin({SPM.xCon.name}, '\n'), opt);
  printToScreen('\n', opt);
end
