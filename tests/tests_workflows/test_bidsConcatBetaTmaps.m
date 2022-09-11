function test_suite = test_bidsConcatBetaTmaps %#ok<*STOUT>
  %
  % (C) Copyright 2019 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsConcatBetaTmapsBasic()

  subLabel = '01';

  opt = setOptions('vismotion', subLabel, 'pipelineType', 'stats');
  opt.dryRun = true;

  opt.model.file = spm_file(opt.model.file, 'filename', 'model-vismotionMVPA_smdl.json');
  opt.model.bm = BidsModel('file', opt.model.file);

  bidsConcatBetaTmaps(opt);

  ffxDir = getFFXdir(subLabel, opt);
  content = bids.util.tsvread(fullfile(ffxDir, ...
                                       'sub-01_task-vismotion_space-IXI549Space_labelfold.tsv'));

  expectedContent = struct('labels', {{'VisMot*bf(1)'; 'VisStat*bf(1)'}}, 'folds', [1; 1]);

  assertEqual(content, expectedContent);

  delete(fullfile(ffxDir, 'sub-01_task-vismotion_space-IXI549Space_labelfold.tsv'));

end
