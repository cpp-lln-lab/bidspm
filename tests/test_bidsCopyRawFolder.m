function test_suite = test_bidsCopyRawFolder %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsCopyRawFolderBasic()

  opt = setOptions('MoAE');

  opt = checkOptions(opt);

  bidsCopyRawFolder(opt, 1);

  layoutRaw = bids.layout(opt.dataDir);
  layoutDerivatives = bids.layout(fullfile(opt.dataDir, '..', 'derivatives', 'cpp_spm'));

  assertEqual(exist( ...
                    fullfile(opt.dataDir, '..', ...
                             'derivatives', 'cpp_spm', ...
                             'dataset_description.json'), 'file'), ...
              2);

  assertEqual(exist( ...
                    fullfile(opt.dataDir, '..', ...
                             'derivatives', 'cpp_spm', 'sub-01', 'func', ...
                             'sub-01_task-auditory_bold.nii'), 'file'), ...
              2);

  assertEqual(exist( ...
                    fullfile(opt.dataDir, '..', ...
                             'derivatives', 'cpp_spm', 'sub-01', 'anat', ...
                             'sub-01_T1w.nii'), 'file'), ...
              2);
end

function test_bidsCopyRawFolder2tasks()

  system('rm -Rf dummyData/copy');

  opt.dataDir = fullfile( ...
                         fileparts(mfilename('fullpath')), ...
                         'dummyData', 'derivatives', 'cpp_spm');

  opt.derivativesDir = fullfile( ...
                                fileparts(mfilename('fullpath')), ...
                                'dummyData', 'copy');

  opt.taskName = 'vismotion';

  opt = checkOptions(opt);

  unZip = false;
  deleteZippedNii = false;
  bidsCopyRawFolder(opt, deleteZippedNii, {'func'}, unZip);

  assertEqual(exist( ...
                    fullfile(opt.derivativesDir, 'derivatives', 'cpp_spm', ...
                             'sub-01', ...
                             'ses-01', ...
                             'func', ...
                             'sub-01_ses-01_task-vismotion_run-1_bold.json'), 'file'), ...
              2);

  opt.taskName = 'vislocalizer';
  bidsCopyRawFolder(opt, deleteZippedNii, {'func'}, unZip);

  BIDS = bids.layout(fullfile(opt.derivativesDir, 'derivatives', 'cpp_spm'));

  modalities = bids.query(BIDS, 'modalities');
  assertEqual(numel(modalities), 1);

  tasks = bids.query(BIDS, 'tasks');
  assertEqual(numel(tasks), 2);

  system('rm -Rf dummyData/copy');

end
