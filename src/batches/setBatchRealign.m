% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function [matlabbatch, voxDim] = setBatchRealign(varargin)
  %
  % Set the batch for realign / realign and reslice / realign and unwarp
  %
  % USAGE::
  %
  %   [matlabbatch, voxDim] = setBatchRealign(matlabbatch, BIDS, subID, opt, [action = 'realign'])
  %
  % :param matlabbatch: SPM batch
  % :type matlabbatch: structure
  % :param BIDS: BIDS layout returned by ``getData``
  % :type BIDS: structure
  % :param subID: subject label
  % :type subID: string
  % :param opt: options
  % :type opt: structure
  % :param action: ``realign``, ``realignReslice``, ``realignUnwarp``
  % :type action: string
  %
  % :returns: - :matlabbatch: (structure) (dimension)
  %           - :voxDim: (array) (dimension)

  [matlabbatch, BIDS, subID, opt, action] = deal(varargin{:});

  if nargin < 5 || isempty(action)
    action = 'realign';
  end

  % TODO hide this wart in a subfunction ?
  switch action
    case 'realignUnwarp'
      msg = ' & UNWARP';
      matlabbatch{end + 1}.spm.spatial.realignunwarp.eoptions.weight = {''};
      matlabbatch{end}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];

    case 'realignReslice'
      msg = ' & RESLICE';
      matlabbatch{end + 1}.spm.spatial.realign.estwrite.eoptions.weight = {''};
      matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];

    case 'realign'
      msg = [];
      matlabbatch{end + 1}.spm.spatial.realign.estwrite.eoptions.weight = {''};
      matlabbatch{end}.spm.spatial.realign.estwrite.roptions.which = [0 1];

  end

  fprintf(1, ' BUILDING SPATIAL JOB : REALIGN%s\n', msg);

  [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

  runCounter = 1;

  for iSes = 1:nbSessions

    % get all runs for that subject across all sessions
    [runs, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      % get the filename for this bold run for this task
      [fileName, subFuncDataDir] = getBoldFilename( ...
                                                   BIDS, ...
                                                   subID, ...
                                                   sessions{iSes}, ...
                                                   runs{iRun}, ...
                                                   opt);

      % check that the file with the right prefix exist and we get and
      % save its voxeldimension
      prefix = getPrefix('preprocess', opt);
      file = validationInputFile(subFuncDataDir, fileName, prefix);
      [voxDim, opt] = getFuncVoxelDims(opt, subFuncDataDir, prefix, fileName);

      if size(file, 1) > 1
        errorStruct.identifier = 'setBatchRealign:tooManyFiles';
        errorStruct.message = 'This should only get on file.';
        error(errorStruct);
      end

      fprintf(1, ' %s\n', file);

      if strcmp(action, 'realignUnwarp')
        matlabbatch{end}.spm.spatial.realignunwarp.data(1, runCounter).pmscan = '';
        matlabbatch{end}.spm.spatial.realignunwarp.data(1, runCounter).scans = { file };
      else
        matlabbatch{end}.spm.spatial.realign.estwrite.data{1, runCounter} = { file };
      end

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
