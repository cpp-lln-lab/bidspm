% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function batch = setBatchSubjectLevelResults(varargin)
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
