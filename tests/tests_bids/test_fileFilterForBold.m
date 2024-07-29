function test_suite = test_fileFilterForBold %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_fileFilterForBold_events()

  opt.bidsFilterFile.bold = struct('modality', 'func', 'suffix', 'bold');
  opt.verbosity = 0;
  opt.taskName = 'foo';
  opt.fwhm.func = 6;
  opt.space = {'IXI549Space'};

  subLabel = '01';

  [filter] = fileFilterForBold(opt, subLabel, 'events');

  expected = struct('extension', '.tsv', ...
                    'modality', 'func', ...
                    'prefix', '', ...
                    'sub', '^01$', ...
                    'suffix', {{'events'}}, ...
                    'task', 'foo');

  assertEqual(filter, expected);

end

function test_fileFilterForBold_events_aroma()

  opt.bidsFilterFile.bold = struct('modality', 'func', ...
                                   'suffix', 'bold', ...
                                   'desc', {'smoothAROMAnonaggr'});
  opt.verbosity = 0;
  opt.taskName = 'foo';
  opt.fwhm.func = 6;
  opt.space = {'MNI152NLin6Asym'};

  subLabel = '01';

  [filter] = fileFilterForBold(opt, subLabel, 'events');

  expected = struct('extension', '.tsv', ...
                    'modality', 'func', ...
                    'prefix', '', ...
                    'sub', '^01$', ...
                    'suffix', {{'events'}}, ...
                    'task', 'foo');

  assertEqual(filter, expected);

end

function test_fileFilterForBold_confounds()

  opt.bidsFilterFile.bold = struct('modality', 'func', 'suffix', 'bold');
  opt.verbosity = 0;
  opt.taskName = 'foo';
  opt.fwhm.func = 6;
  opt.space = {'IXI549Space'};

  subLabel = '01';

  [filter] = fileFilterForBold(opt, subLabel, 'confounds');

  expected = struct('extension', '.tsv', ...
                    'modality', 'func', ...
                    'prefix', '', ...
                    'sub', '^01$', ...
                    'suffix', {{'regressors', 'timeseries', 'outliers', 'motion'}}, ...
                    'task', 'foo');

  assertEqual(filter, expected);

end

function test_fileFilterForBold_basic()

  opt.bidsFilterFile.bold = struct('modality', 'func', 'suffix', 'bold');
  opt.verbosity = 0;
  opt.taskName = 'foo';
  opt.fwhm.func = 6;
  opt.space = {'IXI549Space'};

  subLabel = '01';

  [filter] = fileFilterForBold(opt, subLabel);

  expected = struct('desc', 'smth6', ...
                    'extension', {{'.nii.*'}}, ...
                    'modality', 'func', ...
                    'prefix', '', ...
                    'space', {{'IXI549Space'}}, ...
                    'sub', '^01$', ...
                    'suffix', 'bold', ...
                    'task', 'foo');

  assertEqual(filter, expected);

end

function test_fileFilterForBold_desc()

  opt.bidsFilterFile.bold = struct('modality', 'func', ...
                                   'suffix', 'bold', ...
                                   'desc', {'smoothAROMAnonaggr'});
  opt.verbosity = 0;
  opt.taskName = 'foo';
  opt.fwhm.func = 6;
  opt.space = {'MNI152NLin6Asym'};

  subLabel = '01';

  type = 'glm';

  [filter] = fileFilterForBold(opt, subLabel, type);

  expected = struct('desc', 'smoothAROMAnonaggr', ...
                    'extension', {{'.nii.*'}}, ...
                    'modality', 'func', ...
                    'prefix', '', ...
                    'space', {{'MNI152NLin6Asym'}}, ...
                    'sub', '^01$', ...
                    'suffix', 'bold', ...
                    'task', 'foo');

  assertEqual(filter, expected);

end

function test_fileFilterForBold_no_smooth()

  opt.bidsFilterFile.bold = struct('modality', 'func', 'suffix', 'bold');
  opt.verbosity = 0;
  opt.taskName = 'foo';
  opt.fwhm.func = 0;
  opt.space = {'IXI549Space'};

  subLabel = '01';

  [filter, opt] = fileFilterForBold(opt, subLabel);

  expected = struct('desc', 'preproc', ...
                    'extension', {{'.nii.*'}}, ...
                    'modality', 'func', ...
                    'prefix', '', ...
                    'space', {{'IXI549Space'}}, ...
                    'sub', '^01$', ...
                    'suffix', 'bold', ...
                    'task', 'foo');

  assertEqual(filter, expected);

end

function test_fileFilterForBold_stc()

  opt.bidsFilterFile.bold = struct('modality', 'func', 'suffix', 'bold');
  opt.verbosity = 0;
  opt.taskName = 'foo';
  opt.fwhm.func = 0;
  opt.space = {'IXI549Space'};

  subLabel = '01';

  [filter, opt] = fileFilterForBold(opt, subLabel, 'stc');

  expected = struct('desc', '', ...
                    'extension', {{'.nii.*'}}, ...
                    'modality', 'func', ...
                    'prefix', '', ...
                    'space', '', ...
                    'sub', '^01$', ...
                    'suffix', 'bold', ...
                    'task', 'foo');

  assertEqual(filter, expected);

end
