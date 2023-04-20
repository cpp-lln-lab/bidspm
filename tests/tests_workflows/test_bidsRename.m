% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsRename %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRename_basic()

  % TODO take care of
  % - SpatialReference probably not needed for space individual if anat modality
  % - transfer of Skullstripped true, if sources has it?

  opt = setOptions('MoAE-preproc');

  % move test data into temp directory to test renaming
  tmpDir = tempname;
  spm_mkdir(tmpDir);
  copyfile(opt.dir.preproc, tmpDir);

  bidsDir = tmpDir;
  if bids.internal.is_octave()
    bidsDir = fullfile(tmpDir, 'bidspm-preproc');
  end

  opt.dir.preproc = bidsDir;

  BIDS = bids.layout(bidsDir, 'use_schema', false);

  files = bids.query(BIDS, 'data', 'prefix', '');
  for i = 1:numel(files)
    delete(files{i});
  end

  opt.dryRun = false;
  opt.verbosity = 2;

  createdFiles = bidsRename(opt);

  files = bids.query(BIDS, 'data');
  for i = 1:numel(createdFiles)
    jsonFile = spm_file(createdFiles{i}, 'ext', '.json');
    if exist(jsonFile, 'file')
      content = bids.util.jsondecode(jsonFile);
      if isfield(content, 'SpmFilename')
        assert(size(content.SpmFilename, 1) == 1);
      end
    end
  end

end
