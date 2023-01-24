function test_suite = test_bidsRoiBasedGLM %#ok<*STOUT>

  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRoiBasedGLM_checks()

  opt = setOptions('vislocalizer', '01', 'pipelineType', 'stats');
  opt.model.bm = BidsModel('file', opt.model.file);
  opt.model.bm.Input.space = char(opt.model.bm.Input.space);

  assertExceptionThrown(@() bidsRoiBasedGLM(opt), 'bidsRoiBasedGLM:roiBasedAnalysis');

end

function test_bidsRoiBasedGLM_run()
  %
  % integration test:
  %  - also makes sure that previous results are not deleted
  %

  opt = setOptions('MoAE-fmriprep', '01');

  opt.query.space = opt.space;

  opt.dir.input = opt.dir.fmriprep;

  opt.versbosity = 0;

  bidsCopyInputFolder(opt, 'unzip', true);

  opt.model.file = fullfile(getMoaeDir(), ...
                            'models', ...
                            'model-MoAE_smdl.json');

  opt.model.bm = BidsModel('file', opt.model.file);
  opt.model.bm.Input.space = opt.space;

  opt.glm.roibased.do = true;
  opt.dryRun = false;
  opt.fwhm.func = 0;

  bidsFFX('specify', opt);

  % rmdir(fullfile(pwd, 'options'), 's');

  opt.dir.roi = fullfile(opt.dir.derivatives, 'bidspm-roi');

  opt.roi.atlas = 'wang';
  opt.roi.name = {'V1v', 'V1d'};
  opt.roi.hemisphere = {'L', 'R'};
  opt.roi.space = opt.space;

  opt.bidsFilterFile.roi.space = 'MNI';

  bidsCreateROI(opt);

  opt.roi.name = {'.*V1v'};

  bidsRoiBasedGLM(opt);

  opt.roi.name = {'.*V1d'};

  bidsRoiBasedGLM(opt);

  timecourseFiles = spm_select('FPListRec', opt.dir.stats, '^.*timecourse.tsv$');

  assertEqual(size(timecourseFiles, 1), 4);

  delete('skipped_roi_*.tsv');

end
