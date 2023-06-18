% (C) Copyright 2020 bidspm developers

function test_suite = test_setBatchRealign %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

% TODO
% add test realign and reslice
% check it returns the right voxDim

function test_setBatchRealign_after_stc()

  subLabel = '^01';

  opt = setOptions('vismotion', subLabel);

  % TODO implement opt.bidsFilterFile.bold.acq = '';
  opt.bidsFilterFile.bold.acq = '';
  opt.bidsFilterFile.bold.part = 'mag';

  % some tweaks because we have dummy data
  opt.funcVoxelDims = [2 2 2];
  opt.useFieldmaps = false;

  BIDS = getLayout(opt);

  matlabbatch = {};
  [matlabbatch, voxDim] = setBatchRealign(matlabbatch, BIDS, opt, subLabel);

  expectedBatch{1}.spm.spatial.realignunwarp.eoptions.weight = {''};
  expectedBatch{end}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];

  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

  runCounter = 1;
  for iSes = 1:nbSessions

    [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      fileName = bids.query(BIDS, 'data', ...
                            'prefix', '', ...
                            'sub', subLabel, ...
                            'ses', sessions{iSes}, ...
                            'task', opt.taskName, ...
                            'run', runs{iRun}, ...
                            'acq', '', ...
                            'part', 'mag', ...
                            'desc', 'stc', ...
                            'suffix', 'bold', ...
                            'extension', '.nii');

      expectedBatch{end}.spm.spatial.realignunwarp.data(1, runCounter).pmscan = { '' };
      expectedBatch{end}.spm.spatial.realignunwarp.data(1, runCounter).scans = cellstr(fileName);

      runCounter = runCounter + 1;

    end
  end

  assertEqual(voxDim, [2 2 2]);
  assertEqual(matlabbatch{1}.spm.spatial.realignunwarp.eoptions, ...
              expectedBatch{1}.spm.spatial.realignunwarp.eoptions);
  assertEqual(matlabbatch{1}.spm.spatial.realignunwarp.uwroptions, ...
              expectedBatch{1}.spm.spatial.realignunwarp.uwroptions);
  assertEqual(matlabbatch{1}.spm.spatial.realignunwarp.data, ...
              expectedBatch{1}.spm.spatial.realignunwarp.data);
end

function test_setBatchRealign_anat_only()

  subLabel = '^01';

  opt = setOptions('vismotion', subLabel);
  opt.anatOnly = true;

  BIDS = struct([]);

  matlabbatch = {};
  [matlabbatch, voxDim] = setBatchRealign(matlabbatch, BIDS, opt, subLabel);

  assertEqual(matlabbatch, {});
  assertEqual(voxDim, []);

end

function test_setBatchRealign_select_volumes()

  subLabel = '^01';

  opt = setOptions('MoAE', subLabel);

  opt.funcVolToSelect = 1:2:70;

  [BIDS, opt] = getData(opt, opt.dir.raw);

  matlabbatch = {};
  matlabbatch = setBatchRealign(matlabbatch, BIDS, opt, subLabel);

  assertEqual(size(matlabbatch{1}.spm.spatial.realignunwarp.data(1).scans, 1), ...
              numel(opt.funcVolToSelect));

end

function test_setBatchRealign_basic()

  subLabel = '^01';

  opt = setOptions('MoAE-preproc', subLabel);

  % some tweaks because we have dummy data
  opt.funcVoxelDims = [2 2 2];
  opt.useBidsSchema = false;

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  matlabbatch = {};
  matlabbatch = setBatchRealign(matlabbatch, BIDS, opt, subLabel);

  expectedBatch{1}.spm.spatial.realignunwarp.eoptions.weight = {''};
  expectedBatch{end}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];

  for iSes = 1
    fileName = bids.query(BIDS, 'data', ...
                          'sub', subLabel, ...
                          'task', opt.taskName, ...
                          'desc', '', ...
                          'extension', '.nii', ...
                          'prefix', '', ...
                          'suffix', 'bold');

    expectedBatch{end}.spm.spatial.realignunwarp.data(1, iSes).pmscan = { '' };
    expectedBatch{end}.spm.spatial.realignunwarp.data(1, iSes).scans = cellstr(fileName);
  end

  assertEqual(matlabbatch{1}.spm.spatial.realignunwarp.eoptions, ...
              expectedBatch{1}.spm.spatial.realignunwarp.eoptions);
  assertEqual(matlabbatch{1}.spm.spatial.realignunwarp.uwroptions, ...
              expectedBatch{1}.spm.spatial.realignunwarp.uwroptions);
  assertEqual(matlabbatch{1}.spm.spatial.realignunwarp.data, ...
              expectedBatch{1}.spm.spatial.realignunwarp.data);
end
