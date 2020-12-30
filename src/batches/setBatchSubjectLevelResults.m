% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSubjectLevelResults(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelResults(matlabbatch, opt, subID, funcFWHM, iStep, iCon)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param opt:
  % :type opt: structure
  % :param subID:
  % :type subID: string
  % :param funcFWHM:
  % :type funcFWHM: float
  % :param iStep:
  % :type iStep: positive integer
  % :param iCon:
  % :type iCon: positive integer
  %
  % :returns: - :matlabbatch: (structure)
  %

  [matlabbatch, opt, subID, funcFWHM, iStep, iCon] = deal(varargin{:});

  result.Contrasts = opt.result.Steps(iStep).Contrasts(iCon);

  if isfield(opt.result.Steps(iStep), 'Output')
    result.Output =  opt.result.Steps(iStep).Output;
  end
  result.space = opt.space;

  result.dir = getFFXdir(subID, funcFWHM, opt);
  result.label = subID;
  result.nbSubj = 1;

  result.contrastNb = getContrastNb(result);

  matlabbatch = setBatchResults(matlabbatch, result);

end

function contrastNb = getContrastNb(result)
  %
  % identify which contrast nb actually has the name the user asked
  %

  load(fullfile(result.dir, 'SPM.mat'));

  if isempty(result.Contrasts.Name)

    printAvailabileContrasts(SPM);

    errorStruct.identifier = 'setBatchSubjectLevelResults:missingContrastName';
    errorStruct.message = 'No contrast name specified';
    error(errorStruct);

  end

  contrastNb = find(strcmp({SPM.xCon.name}', result.Contrasts.Name));

  if isempty(contrastNb)

    printAvailabileContrasts(SPM);

    errorStruct.identifier = 'setBatchSubjectLevelResults:NoMatchingContrastName';
    errorStruct.message = sprintf( ...
                                  'This SPM file %s does not contain a contrast named %s', ...
                                  fullfile(result.dir, 'SPM.mat'), ...
                                  result.Contrasts.Name);

    error(errorStruct);

  end

end

function printAvailabileContrasts(SPM)
  sprintf('List of contrast in this SPM file');
  disp({SPM.xCon.name}');
end
