function test_suite = test_setBatchCoregistrationFuncToAnat %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchCoregistrationFuncToAnatBasic()

  % necessarry to deal with SPM module dependencies
  spm_jobman('initcfg');

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.taskName = 'vismotion';

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  subID = '02';

  opt.orderBatches.selectAnat = 1;
  opt.orderBatches.realign = 2;

  matlabbatch = {};
  matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, opt, subID);

  nbRuns = 4;

  meanImageToUse = 'meanuwr';
  otherImageToUse = 'uwrfiles';

  expectedBatch = returnExpectedBatch(nbRuns, meanImageToUse, otherImageToUse);
  assertEqual( ...
              matlabbatch{1}.spm.spatial.coreg.estimate.ref, ...
              expectedBatch{1}.spm.spatial.coreg.estimate.ref);
  assertEqual( ...
              matlabbatch{1}.spm.spatial.coreg.estimate.source, ...
              expectedBatch{1}.spm.spatial.coreg.estimate.source);
  assertEqual( ...
              matlabbatch{1}.spm.spatial.coreg.estimate.other, ...
              expectedBatch{1}.spm.spatial.coreg.estimate.other);

end

function test_setBatchCoregistrationFuncToAnatNoUnwarp()

  % necessarry to deal with SPM module dependencies
  spm_jobman('initcfg');

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.taskName = 'vismotion';
  opt.realign.useUnwarp = false;

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  subID = '02';

  opt.orderBatches.selectAnat = 1;
  opt.orderBatches.realign = 2;

  matlabbatch = {};
  matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, opt, subID);

  nbRuns = 4;

  meanImageToUse = 'rmean';
  otherImageToUse = 'cfiles';

  expectedBatch = returnExpectedBatch(nbRuns, meanImageToUse, otherImageToUse);
  assertEqual( ...
              matlabbatch{1}.spm.spatial.coreg.estimate.ref, ...
              expectedBatch{1}.spm.spatial.coreg.estimate.ref);
  assertEqual( ...
              matlabbatch{1}.spm.spatial.coreg.estimate.source, ...
              expectedBatch{1}.spm.spatial.coreg.estimate.source);
  assertEqual( ...
              matlabbatch{1}.spm.spatial.coreg.estimate.other, ...
              expectedBatch{1}.spm.spatial.coreg.estimate.other);

end

function expectedBatch = returnExpectedBatch(nbRuns, meanImageToUse, otherImageToUse)

  expectedBatch = {};

  expectedBatch{end + 1}.spm.spatial.coreg.estimate.ref(1) = ...
      cfg_dep('Named File Selector: Anatomical(1) - Files', ...
              substruct( ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}), ...
              substruct('.', 'files', '{}', {1}));

  expectedBatch{end}.spm.spatial.coreg.estimate.source(1) = ...
      cfg_dep('Realign: Estimate & Reslice/Unwarp: Mean Image', ...
              substruct( ...
                        '.', 'val', '{}', {2}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}), ...
              substruct('.', meanImageToUse));

  for iRun = 1:nbRuns

    stringToUse = sprintf( ...
                          'Realign: Estimate & Reslice/Unwarp: Realigned Images (Sess %i)', ...
                          iRun);

    expectedBatch{end}.spm.spatial.coreg.estimate.other(iRun) = ...
        cfg_dep(stringToUse, ...
                substruct( ...
                          '.', 'val', '{}', {2}, ...
                          '.', 'val', '{}', {1}, ...
                          '.', 'val', '{}', {1}, ...
                          '.', 'val', '{}', {1}), ...
                substruct( ...
                          '.', 'sess', '()', {iRun}, ...
                          '.', otherImageToUse));

  end

end
