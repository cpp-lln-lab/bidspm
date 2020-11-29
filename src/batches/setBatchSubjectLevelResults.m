% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSubjectLevelResults(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelResults(matlabbatch, grp, funcFWHM, opt, iStep, iCon)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param grp:
  % :type grp:
  % :param funcFWHM:
  % :type funcFWHM: float
  % :param opt:
  % :type opt: structure
  % :param iStep:
  % :type iStep: positive integer
  % :param iCon:
  % :type iCon: positive integer
  %
  % :returns: - :matlabbatch: (structure)
  %

  [matlabbatch, grp, funcFWHM, opt, iStep, iCon] = deal(varargin{:});

  for iGroup = 1:length(grp)

    % For each subject
    for iSub = 1:grp(iGroup).numSub

      % Get the Subject ID
      subID = grp(iGroup).subNumber{iSub};

      % FFX Directory
      ffxDir = getFFXdir(subID, funcFWHM, opt);

      load(fullfile(ffxDir, 'SPM.mat'));

      % identify which contrast nb actually has the name the user asked
      conNb = find( ...
                   strcmp({SPM.xCon.name}', ...
                          opt.result.Steps(iStep).Contrasts(iCon).Name));

      if isempty(conNb)
        sprintf('List of contrast in this SPM file');
        disp({SPM.xCon.name}');
        error( ...
              'This SPM file %s does not contain a contrast named %s', ...
              fullfile(ffxDir, 'SPM.mat'), ...
              opt.result.Steps(1).Contrasts(iCon).Name);
      end

      results.dir = ffxDir;
      results.contrastNb = conNb;
      results.label = subID;
      results.nbSubj = 1;

      matlabbatch = setBatchResults(matlabbatch, opt, iStep, iCon, results);

    end
  end

end
