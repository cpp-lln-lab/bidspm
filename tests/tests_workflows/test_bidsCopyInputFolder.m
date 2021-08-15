% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_bidsCopyInputFolder %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsCopyInputFolder_basic()

  opt = setOptions('MoAE');

  bidsCopyInputFolder(opt, true());

  layoutRaw = bids.layout(opt.dir.raw);
  layoutDerivatives = bids.layout(fullfile(opt.dir.preproc));

  assertEqual(exist( ...
                    fullfile(opt.dir.raw, '..', ...
                             'derivatives', 'cpp_spm-preproc', ...
                             'dataset_description.json'), 'file'), ...
              2);

  assertEqual(exist( ...
                    fullfile(opt.dir.raw, '..', ...
                             'derivatives', 'cpp_spm-preproc', 'sub-01', 'func', ...
                             'sub-01_task-auditory_bold.nii'), 'file'), ...
              2);

  assertEqual(exist( ...
                    fullfile(opt.dir.raw, '..', ...
                             'derivatives', 'cpp_spm-preproc', 'sub-01', 'anat', ...
                             'sub-01_T1w.nii'), 'file'), ...
              2);

  cleanUp(opt.dir.preproc);

end

function test_bidsCopyInputFolder_fmriprep()

  opt = setOptions('fmriprep');
  opt.query.space = 'MNI152NLin2009cAsym';
  opt.query.desc = 'preproc';

  bidsCopyInputFolder(opt, false());

  layoutDerivatives = bids.layout(fullfile(opt.dir.preproc), false());
  data = bids.query(layoutDerivatives, 'data', 'extension', '.nii.gz');
  assertEqual(size(data, 1), 16);

  cleanUp(opt.dir.preproc);

end

function cleanUp(folder)

  pause(1);

  if isOctave()
    confirm_recursive_rmdir (true, 'local');
  end
  rmdir(folder, 's');

end
