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

  if isfield(opt.result.Nodes(iNode), 'Output')
    result.Output =  opt.result.Nodes(iNode).Output;
  end
  result.space = opt.space;

  result.dir = getFFXdir(subLabel, opt);
  result.label = subLabel;
  result.nbSubj = 1;

  result.contrastNb = getContrastNb(result, opt);

  result.outputNameStructure = struct( ...
                                      'suffix', 'spmT', ...
                                      'ext', '.nii', ...
                                      'use_schema', 'false', ...
                                      'entities', struct('sub', '', ...
                                                         'task', opt.taskName, ...
                                                         'space', opt.space, ...
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
                  'This SPM file %s does not contain a contrast named %s', ...
                  fullfile(result.dir, 'SPM.mat'), ...
                  result.Contrasts.Name);

    errorHandling(mfilename(), 'noMatchingContrastName', msg, false, true);

  end

end

function printAvailableContrasts(SPM, opt)
  printToScreen('List of contrast in this SPM file', opt);
  printToScreen(strjoin({SPM.xCon.name}, '\n'), opt);
end
