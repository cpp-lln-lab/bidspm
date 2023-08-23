function test_suite = test_concatenateImages %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_concatenateImages_basic()

  tempPath = tempName();

  imageSrc = fullfile(getMoaeDir(), 'inputs', 'raw', ...
                      'sub-01', 'func', 'sub-01_task-auditory_bold.nii');

  image1 = fullfile(tempPath, 'sub-01_task-auditory_run-1_bold.nii');
  copyfile(imageSrc, image1);

  image2 = fullfile(tempPath, 'sub-01_task-auditory_run-02_bold.nii');
  copyfile(imageSrc, image2);

  %% run 1
  sess(1).scans{1} = image1;

  [volumeList, nbScans] = concatenateImages(sess);

  assertEqual(volumeList, image1);
  assertEqual(nbScans, 84);

  %% run 2
  sess(2).scans{1} = image2;

  [volumeList, nbScans] = concatenateImages(sess);

  assertEqual(size(volumeList, 1), 84 * 2);
  assertEqual(nbScans, [84, 84]);

end

function test_concatenateImages_specific_volumes()

  tempPath = tempName();

  imageSrc = fullfile(getMoaeDir(), 'inputs', 'raw', ...
                      'sub-01', 'func', 'sub-01_task-auditory_bold.nii');

  image1 = fullfile(tempPath, 'sub-01_task-auditory_run-1_bold.nii');
  copyfile(imageSrc, image1);

  image2 = fullfile(tempPath, 'sub-01_task-auditory_run-02_bold.nii');
  copyfile(imageSrc, image2);

  %% run 1
  sess(1).scans{1} = [image1 ',01'
                      image1 ',02'];

  [volumeList, nbScans] = concatenateImages(sess);

  assertEqual(volumeList, [image1 ',01'
                           image1 ',02']);
  assertEqual(nbScans, 2);

  %% run 2
  sess(2).scans{1} = [image2 ',01'
                      image2 ',02'
                      image2 ',03'];

  [volumeList, nbScans] = concatenateImages(sess);

  assertEqual(volumeList, [image1 ',01 '
                           image1 ',02 '
                           image2 ',01'
                           image2 ',02'
                           image2 ',03']);
  assertEqual(nbScans, [2, 3]);

end
