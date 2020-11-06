% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function batch = setBatchSubjectLevelResults(varargin)

    [batch, grp, funcFWHM, opt, iStep, iCon] = deal(varargin{:});
  
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
  
        batch = setBatchResults(batch, opt, iStep, iCon, results);
  
      end
    end
  
  end