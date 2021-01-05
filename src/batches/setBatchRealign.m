% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function [matlabbatch, voxDim] = setBatchRealign(varargin)
  %
  % Set the batch for realign / realign and reslice / realign and unwarp
  %
  % USAGE::
  %
  %   [matlabbatch, voxDim] = setBatchRealign(matlabbatch, [action = 'realign'], BIDS, opt, subID)
  %
  % :param matlabbatch: SPM batch
  % :type matlabbatch: structure
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param action: ``realign``, ``realignReslice``, ``realignUnwarp``
  % :type action: string
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :type subID: string
  % :param subID: subject label
  %
  % :returns: - :matlabbatch: (structure) (dimension)
  %           - :voxDim: (array) (dimension)

  % TODO:
  % make which image is resliced more consistent 'which = []'

  if numel(varargin) < 5
    [matlabbatch, BIDS, opt, subID] = deal(varargin{:});
    action = '';
  else
    [matlabbatch, action, BIDS, opt, subID] = deal(varargin{:});
  end

  if isempty(action)
    action = 'realignUnwarp';
  end

  % TODO hide this wart in a subfunction ?
  switch action
    case 'realignUnwarp'
      msg = 'REALIGN & UNWARP';
      matlabbatch{end + 1}.spm.spatial.realignunwarp.eoptions.weight = {''};
      matlabbatch{end}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];

    case 'realignReslice'
      msg = 'REALIGN & RESLICE';
      matlabbatch{end + 1}.spm.spatial.realign.estwrite.eoptions.weight = {''};
      matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];

    case 'realign'
      msg = 'REALIGN';
      matlabbatch{end + 1}.spm.spatial.realign.estwrite.eoptions.weight = {''};
      matlabbatch{end}.spm.spatial.realign.estwrite.roptions.which = [0 1];

    case 'reslice'
      msg = 'RESLICE';
      matlabbatch{end + 1}.spm.spatial.realign.write.roptions.which = [2 0];

  end

  printBatchName(msg);

  [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

  runCounter = 1;

  for iSes = 1:nbSessions

    % get all runs for that subject across all sessions
    [runs, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      % get the filename for this bold run for this task
      [boldFilename, subFuncDataDir] = getBoldFilename( ...
                                                       BIDS, ...
                                                       subID, ...
                                                       sessions{iSes}, ...
                                                       runs{iRun}, ...
                                                       opt);

      % check that the file with the right prefix exist and we get and
      % save its voxeldimension
      prefix = getPrefix('realign', opt);
      file = validationInputFile(subFuncDataDir, boldFilename, prefix);
      [voxDim, opt] = getFuncVoxelDims(opt, subFuncDataDir, prefix, boldFilename);

      if size(file, 1) > 1
        errorStruct.identifier = 'setBatchRealign:tooManyFiles';
        errorStruct.message = 'This should only get on file.';
        error(errorStruct);
      end

      switch action

        % we reslice images that come from a previous batch so we can return
        % early
        case 'reslice'

          matlabbatch{end}.spm.spatial.realign.write.data(1) = ...
            cfg_dep('Coregister: Estimate: Coregistered Images', ...
                    substruct( ...
                              '.', 'val', '{}', {opt.orderBatches.coregister}, ...
                              '.', 'val', '{}', {1}, ...
                              '.', 'val', '{}', {1}, ...
                              '.', 'val', '{}', {1}), ...
                    substruct('.', 'cfiles'));

          return

        case 'realignUnwarp'

          vdmFile = getVdmFile(BIDS, opt, boldFilename);
          matlabbatch{end}.spm.spatial.realignunwarp.data(1, runCounter).pmscan = { vdmFile };
          matlabbatch{end}.spm.spatial.realignunwarp.data(1, runCounter).scans = { file };

        otherwise

          matlabbatch{end}.spm.spatial.realign.estwrite.data{1, runCounter} = { file };

      end

      fprintf(1, ' %s\n', file);

      runCounter = runCounter + 1;
    end

  end

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
