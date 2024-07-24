% (C) Copyright 2020 bidspm developers

function test_suite = test_setBatchCoregistrationFuncToAnat %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchCoregistrationFuncToAnat_anat_only()

  subLabel = '^01';

  opt = setOptions('vismotion', subLabel);
  opt.anatOnly = true;

  BIDS = cell(1);

  matlabbatch = {};
  matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, opt, subLabel);

  assertEqual(matlabbatch, {});

end

function test_setBatchCoregistrationFuncToAnat_basic()

  subLabel = '01';

  opt = setOptions('vismotion', subLabel);

  BIDS = getLayout(opt);

  opt.orderBatches.selectAnat = 1;
  opt.orderBatches.realign = 2;

  matlabbatch = {};
  matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, opt, subLabel);

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

function test_setBatchCoregistrationFuncToAnat_one_session()

  subLabel = '01';

  opt = setOptions('vismotion', subLabel);

  opt.bidsFilterFile.bold.ses = '02';

  BIDS = getLayout(opt);

  opt.orderBatches.selectAnat = 1;
  opt.orderBatches.realign = 2;

  matlabbatch = {};
  matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, opt, subLabel);

  nbRuns = 2;

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

function test_setBatchCoregistrationFuncToAnat_no_unwarp()

  subLabel = '01';

  opt = setOptions('vismotion', subLabel);
  opt.realign.useUnwarp = false;

  BIDS = getLayout(opt);

  opt.orderBatches.selectAnat = 1;
  opt.orderBatches.realign = 2;

  matlabbatch = {};
  matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, opt, subLabel);

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
