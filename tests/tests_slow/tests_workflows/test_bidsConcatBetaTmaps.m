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

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  subLabel = '01';

  opt = setOptions('vismotion', subLabel, 'pipelineType', 'stats');
  opt.dryRun = true;

  opt.model.file = spm_file(opt.model.file, 'filename', 'model-vismotionMVPA_smdl.json');
  opt.model.bm = BidsModel('file', opt.model.file);

  tmpDir = tempName();
  copyfile(opt.dir.stats, tmpDir);

  opt.dir.stats = tmpDir;

  % update content of FFX dir to mock 2 sessions
  targetDir = fullfile(opt.dir.stats, ...
                       ['sub-' subLabel], ...
                       'task-vismotion_space-IXI549Space_FWHM-6');

  prefixes = {'beta', 'spmT'};
  for iPrefix = 1:numel(prefixes)
    files = spm_select('FPList', targetDir, ['^' prefixes{iPrefix} '.*nii']);
    for i = 1:size(files, 1)
      number = sprintf('%04.0f', i + size(files, 1));
      newFile = spm_file(files(i, :), ...
                         'filename', ...
                         ['beta_' number '.nii']);
      copyfile(files(i, :), newFile);
    end
  end

  load(fullfile(targetDir, 'SPM.mat'), 'SPM');

  names = SPM.xX.name; %#ok<*NODEF>
  for i = 1:numel(SPM.xX.name)
    new_name = strrep(names{i}, 'Sn(1)', 'Sn(2)');
    names{end + 1} = new_name; %#ok<AGROW>
  end
  SPM.xX.name = names;

  SPM.Sess(2).col = SPM.Sess(1).col + numel(SPM.Sess(1).col);
  SPM.Sess(2).row = SPM.Sess(1).row + numel(SPM.Sess(1).row);

  SPM.xX.X = repmat(SPM.xX.X, [1, 2]);
  filesSes2 = SPM.xY.P;
  filesSes2 = regexprep(cellstr(filesSes2), 'ses-01', 'ses-02');
  SPM.xY.P = cat(1, SPM.xY.P, char(filesSes2));

  save(fullfile(targetDir, 'SPM.mat'), 'SPM');

  %% act
  bidsConcatBetaTmaps(opt);

  %% assert
  ffxDir = getFFXdir(subLabel, opt);
  content = bids.util.tsvread(fullfile(ffxDir, ...
                                       'sub-01_task-vismotion_space-IXI549Space_labelfold.tsv'));

  expectedContent = struct('labels', {{'VisMot*bf(1)'; ...
                                       'VisMot*bf(1)'; ...
                                       'VisStat*bf(1)'; ...
                                       'VisStat*bf(1)'}}, ...
                           'folds', [1; 2; 1; 2]);

  assertEqual(content, expectedContent);

end
