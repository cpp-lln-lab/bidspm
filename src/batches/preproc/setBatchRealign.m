function [matlabbatch, voxDim] = setBatchRealign(varargin)
  %
  % Set the batch for realign / realign and reslice / realign and unwarp
  %
  % USAGE::
  %
  %   [matlabbatch, voxDim] = setBatchRealign(matlabbatch, ...
  %                                           BIDS, ...
  %                                           opt, ...
  %                                           subLabel, ...
  %                                           [action = 'realign'])
  %
  % :param matlabbatch: SPM batch
  % :type matlabbatch: cell
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param subLabel: subject label
  % :type subLabel: string
  % :param action: ``realign``, ``realignReslice``, ``realignUnwarp``, ``'reslice'``
  % :type action: string
  %
  % :returns: - :matlabbatch: (structure) (dimension)
  %           - :voxDim: (array) (dimension)
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  % TODO  make which image is resliced more consistent 'which = []'

  p = inputParser;

  defaultAction = 'realignUnwarp';
  allowedActions = @(x) ischar(x) && ...
                        ismember(lower(x), ...
                                 {'realignunwarp', ...
                                  'realignreslice', ...
                                  'realign', ...
                                  'reslice'});

  addRequired(p, 'matlabbatch', @iscell);
  addRequired(p, 'BIDS', @isstruct);
  addRequired(p, 'opt', @isstruct);
  addRequired(p, 'subLabel', @ischar);
  addOptional(p, 'action', defaultAction, allowedActions);

  parse(p, varargin{:});

  matlabbatch = p.Results.matlabbatch;
  BIDS = p.Results.BIDS;
  opt = p.Results.opt;
  subLabel = p.Results.subLabel;
  action = p.Results.action;

  if opt.anatOnly
    voxDim = [];
    return
  end

  msg = '';
  switch action
    case 'realignUnwarp'
      msg = 'REALIGN & UNWARP';
      spatial.realignunwarp.eoptions.weight = {''};
      spatial.realignunwarp.uwroptions.uwwhich = [2 1];

    case 'realignReslice'
      msg = 'REALIGN & RESLICE';
      spatial.realign.estwrite.eoptions.weight = {''};
      spatial.realign.estwrite.roptions.which = [2 1];

    case 'realign'
      msg = 'REALIGN';
      spatial.realign.estwrite.eoptions.weight = {''};
      spatial.realign.estwrite.roptions.which = [0 1];

    case 'reslice'
      msg = 'RESLICE';
      spatial.realign.write.roptions.which = [2 0];

  end

  printBatchName(msg, opt);

  runCounter = 1;

  for iTask = 1:numel(opt.taskName)

    opt.query.task = opt.taskName{iTask};

    [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

    for iSes = 1:nbSessions

      % get all runs for that subject across all sessions
      [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

      for iRun = 1:nbRuns

        % get the filename for this bold run for this task
        % in case we did slice timing we specify it in the file to query
        opt.query.desc = '';
        opt = addStcToQuery(BIDS, opt, subLabel);
        [boldFilename, subFuncDataDir] = getBoldFilename( ...
                                                         BIDS, ...
                                                         subLabel, ...
                                                         sessions{iSes}, ...
                                                         runs{iRun}, ...
                                                         opt);

        if size(boldFilename, 1) > 1
          errorHandling(mfilename(), ...
                        'tooManyFiles', ...
                        'This should only get one file.', ...
                        false, ...
                        true);
        end

        % TODO voxDim might be different for different tasks
        % could be important to keep track off for the normalization step later
        [voxDim, opt] = getFuncVoxelDims(opt, subFuncDataDir, boldFilename);

        file = fullfile(subFuncDataDir, boldFilename);
        volumes = returnVolumeList(opt, file);

        switch action

          % we reslice images that come from a previous batch
          % so we can return early
          case 'reslice'

            % TODO voxDim might be different for different tasks
            % reslicing might change the voxel dimension for some tasks.

            spatial.realign.write.data(1) = ...
                cfg_dep('Coregister: Estimate: Coregistered Images', ...
                        returnDependency(opt, 'coregister'), ...
                        substruct('.', 'cfiles'));
            matlabbatch{end + 1}.spm.spatial = spatial;
            return

          case 'realignUnwarp'
            vdmFile = getVdmFile(BIDS, opt, boldFilename);
            spatial.realignunwarp.data(1, runCounter).pmscan = { vdmFile };
            spatial.realignunwarp.data(1, runCounter).scans = volumes;

          otherwise
            spatial.realign.estwrite.data{1, runCounter} = volumes;

        end

        runCounter = runCounter + 1;
      end

    end

  end

  matlabbatch{end + 1}.spm.spatial = spatial;

  %% defaults
  % The following lines are commented out because those parameters
  % can be set in the spm_my_defaults.m

  % -----------------
  % REALIGN
  % REALIGN & RESLICE
  % -----------------
  %
  % matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.quality = 1;
  % matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.sep = 2;
  % matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
  % matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.rtm = 0;
  % matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.interp = 2;
  % matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
  %
  % matlabbatch{end}.spm.spatial.realign.estwrite.roptions.interp = 3;
  % matlabbatch{end}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
  % matlabbatch{end}.spm.spatial.realign.estwrite.roptions.mask = 1;

  % ----------------
  % REALIGN & UNWARP
  % ----------------
  %   matlabbatch{1}.spm.spatial.realignunwarp.eoptions.quality = 1;
  %   matlabbatch{1}.spm.spatial.realignunwarp.eoptions.sep = 2;
  %   matlabbatch{1}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
  %   matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm = 0;
  %   matlabbatch{1}.spm.spatial.realignunwarp.eoptions.einterp = 2;
  %   matlabbatch{1}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
  %
  %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
  %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
  %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
  %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.jm = 0;
  %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
  %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.sot = [];
  %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
  %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.rem = 1;
  %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.noi = 5;
  %   matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
  %
  %   matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.rinterp = 3;
  %   matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
  %   matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.mask = 1;

end
