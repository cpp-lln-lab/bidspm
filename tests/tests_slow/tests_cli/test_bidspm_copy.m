function test_suite = test_bidspm_copy %#ok<*STOUT>

  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_copy_simple_filter()

  markTestAs('slow');

  inputPath = fullfile(getMoaeDir(), 'inputs', 'fmriprep');

  % add dummy aroma file to input folder
  BIDS = bids.layout(inputPath, ...
                     'verbose', false, ...
                     'use_schema', false);
  sourceFile = bids.query(BIDS, 'data', ...
                          'suffix', 'bold', ...
                          'desc', 'preproc', ...
                          'space', 'T1w');
  bf = bids.File(sourceFile{1});
  bf.entities.desc = 'smoothAROMAnonaggr';
  bf = bf.update;
  destFile = bids.internal.file_utils(sourceFile, 'filename', bf.filename);
  if exist(destFile{1}, 'file')
    delete(destFile{1});
  end
  copyfile(sourceFile{1}, destFile{1});

  % simple filter file
  bids_filter_file = fullfile(tempName(), 'bids_filter_file.json');
  bids.util.jsonencode(bids_filter_file, ...
                       struct('bold', struct('modality', 'func', ...
                                             'extension', '.nii.gz', ...
                                             'desc', {{'preproc', 'brain'}})));

  % filter takes precedence over predefined opt.query
  % so anat should not be copied
  opt.query.modality = {'anat'};

  outputPath = tempName();

  bidspm(inputPath, outputPath, 'subject', ...
         'action', 'copy', ...
         'task', {'auditory'}, ...
         'space', {'MNI152NLin6Asym', 'T1w'}, ...
         'bids_filter_file', bids_filter_file, ...
         'verbosity', 0, ...
         'options', opt);

  BIDS = bids.layout(fullfile(outputPath, 'derivatives', 'bidspm-preproc'), ...
                     'verbose', false, ...
                     'use_schema', false);

  assertEqual(numel(bids.query(BIDS, 'data')), 4);

  delete(destFile{1});

end

function test_copy_complex_filter()

  markTestAs('slow');

  inputPath = fullfile(getMoaeDir(), 'inputs', 'fmriprep');

  % add dummy aroma file to input folder
  BIDS = bids.layout(inputPath, ...
                     'verbose', false, ...
                     'use_schema', false);
  sourceFile = bids.query(BIDS, 'data', ...
                          'suffix', 'bold', ...
                          'desc', 'preproc', ...
                          'space', 'T1w');
  bf = bids.File(sourceFile{1});
  bf.entities.desc = 'smoothAROMAnonaggr';
  bf = bf.update;
  destFile = bids.internal.file_utils(sourceFile, 'filename', bf.filename);
  if exist(destFile{1}, 'file')
    delete(destFile{1});
  end
  copyfile(sourceFile{1}, destFile{1});

  % more complex filter as struct
  bids_filter_file = struct('bold', struct('modality', 'func', ...
                                           'suffix', 'bold', ...
                                           'desc', {{'smoothAROMAnonaggr'; ...
                                                     'preproc'}}), ...
                            'anat', struct('modality', 'anat', ...
                                           'suffix', 't1w', ...
                                           'desc', 'preproc'));

  outputPath = tempName();

  bidspm(inputPath, outputPath, 'subject', ...
         'action', 'copy', ...
         'task', {'auditory'}, ...
         'space', {'MNI152NLin6Asym', 'T1w'}, ...
         'bids_filter_file', bids_filter_file, ...
         'verbosity', 0);

  BIDS = bids.layout(fullfile(outputPath, 'derivatives', 'bidspm-preproc'), ...
                     'verbose', false, ...
                     'use_schema', false);

  assertEqual(numel(bids.query(BIDS, 'data')), 4);

  delete(destFile{1});

end

function test_copy()

  markTestAs('slow');

  inputPath = fullfile(getMoaeDir(), 'inputs', 'fmriprep');

  outputPath = tempName();

  bidspm(inputPath, outputPath, 'subject', ...
         'action', 'copy', ...
         'task', {'auditory'}, ...
         'space', {'MNI152NLin6Asym', 'T1w'}, ...
         'verbosity', 0);

  BIDS = bids.layout(fullfile(outputPath, 'derivatives', 'bidspm-preproc'), ...
                     'verbose', false, ...
                     'use_schema', false);

  assertEqual(numel(bids.query(BIDS, 'data')), 7);

  % check that do no overwrite by default
  % TODO
  % bids.matlab still copies nii.gz because the files were unzipped
  % force should be able to detect unzipped versions of files
  bidspm(inputPath, outputPath, 'subject', ...
         'action', 'copy', ...
         'task', {'auditory'}, ...
         'space', {'MNI152NLin6Asym'}, ...
         'verbosity', 0);

  BIDS = bids.layout(fullfile(outputPath, 'derivatives', 'bidspm-preproc'), ...
                     'verbose', false, ...
                     'use_schema', false);

  assertEqual(numel(bids.query(BIDS, 'data')), 7);

end

function test_copy_anat_only()

  markTestAs('slow');

  inputPath = fullfile(getMoaeDir(), 'inputs', 'fmriprep');

  outputPath = tempName();

  bidspm(inputPath, outputPath, 'subject', ...
         'action', 'copy', ...
         'task', {'auditory'}, ...
         'space', {'MNI152NLin6Asym', 'T1w'}, ...
         'anat_only', true, ...
         'verbosity', 0);

  BIDS = bids.layout(fullfile(outputPath, 'derivatives', 'bidspm-preproc'), ...
                     'verbose', false, ...
                     'use_schema', false);

  assertEqual(numel(bids.query(BIDS, 'data')), 2);

end

function test_copy_only_one_task()

  markTestAs('slow');

  inputPath = fullfile(getMoaeDir(), 'inputs', 'fmriprep');

  % add dummy foo task file to input folder
  BIDS = bids.layout(inputPath, ...
                     'verbose', false, ...
                     'use_schema', false);
  sourceFile = bids.query(BIDS, 'data', ...
                          'suffix', 'bold', ...
                          'desc', 'preproc', ...
                          'space', 'T1w');
  bf = bids.File(sourceFile{1});
  bf.entities.task = 'foo';
  bf = bf.update;
  destFile = bids.internal.file_utils(sourceFile, 'filename', bf.filename);
  if exist(destFile{1}, 'file')
    delete(destFile{1});
  end
  copyfile(sourceFile{1}, destFile{1});

  outputPath = tempName();

  bidspm(inputPath, outputPath, 'subject', ...
         'action', 'copy', ...
         'task', {'foo'}, ...
         'space', {'T1w'}, ...
         'verbosity', 0);

  BIDS = bids.layout(fullfile(outputPath, 'derivatives', 'bidspm-preproc'), ...
                     'verbose', false, ...
                     'use_schema', false);

  assertEqual(numel(bids.query(BIDS, 'data')), 1);

  delete(destFile{1});

end
