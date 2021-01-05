function test_suite = test_setBatchGZip %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchGZipBasic()

  unzippedNiifiles = 'sub-01_ses-01_T1w.nii';

  matlabbatch = [];
  matlabbatch = setBatchGZip(matlabbatch, unzippedNiifiles);

  expectedBatch{1}.cfg_basicio.file_dir.file_ops.cfg_gzip_files.files = 'sub-01_ses-01_T1w.nii';
  expectedBatch{1}.cfg_basicio.file_dir.file_ops.cfg_gzip_files.outdir = {''};
  expectedBatch{1}.cfg_basicio.file_dir.file_ops.cfg_gzip_files.keep = false();

  assertEqual(matlabbatch, expectedBatch);

end
