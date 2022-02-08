function test_suite = test_bidsConcatBetaTmaps %#ok<*STOUT>
  %
  % (C) Copyright 2019 CPP_SPM developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsConcatBetaTmapsBasic()

  subLabel = '01';
  funcFWHM = 6;

  opt = setOptions('vismotion', subLabel);
  opt.dryRun = true;

  opt.model.file = spm_file(opt.model.file, 'filename', 'model-vismotionMVPA_smdl.json');

  bidsConcatBetaTmaps(opt, funcFWHM);

  ffxDir = getFFXdir(subLabel, funcFWHM, opt);
  content = bids.util.tsvread(fullfile(ffxDir, ...
                                       'sub-01_task-vismotion_space-MNI_labelfold.tsv'));

  expectedContent = struct('labels', {{'VisMot*bf(1)'; 'VisStat*bf(1)'}}, 'folds', [1; 1]);

  assertEqual(content, expectedContent);

  delete(fullfile(ffxDir, 'sub-01_task-vismotion_space-MNI_labelfold.tsv'));

end
