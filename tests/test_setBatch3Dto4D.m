function test_suite = test_setBatch3Dto4D %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatch3Dto4DBasic()

  volumesList = [ ...
                 fullfile(pwd, 'sub-01_task-rest_bold.nii,1'); ...
                 fullfile(pwd, 'sub-01_task-rest_bold.nii,2')];

  RT = 2;

  matlabbatch = [];
  matlabbatch = setBatch3Dto4D(matlabbatch, volumesList, RT);

  expectedBatch{1}.spm.util.cat.vols = volumesList;
  expectedBatch{1}.spm.util.cat.name = fullfile(pwd, 'sub-01_task-rest_bold_4D.nii');
  expectedBatch{1}.spm.util.cat.dtype = 0;
  expectedBatch{1}.spm.util.cat.RT = 2;

  assertEqual(matlabbatch, expectedBatch);

end
