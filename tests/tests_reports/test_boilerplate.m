function test_suite = test_boilerplate %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_boilerplate_spatial_preproc()

  % GIVEN

  opt = setOptions('MoAE-preproc');

  filter = opt.bidsFilterFile.bold;
  filter.task = opt.taskName;

  opt.stc.referenceSlice = 32;

  opt.dummy_scans = 4;

  %  opt.space = {'individual'};

  %  opt.realign.useUnwarp = false;

  %  opt.fwhm.func = 0;

  outputFile = boilerplate(opt, ...
                           'outputPath', pwd, ...
                           'pipelineType', 'preproc', ...
                           'partialsPath', partialsPapth(), ...
                           'verbosity', 0);

  assertEqual(exist(outputFile, 'file'), 2);
  delete(outputFile);
  delete('bidspm.bib');

end

function test_boilerplate_spatial_subject_glm()

  % GIVEN

  opt = setOptions('facerep');

  opt.fwhm.contrast = 0;

  opt.designType = 'block';

  outputFile = boilerplate(opt, ...
                           'outputPath', pwd, ...
                           'pipelineType', 'stats', ...
                           'partialsPath', partialsPapth(), ...
                           'verbosity', 0);

  assertEqual(exist(outputFile, 'file'), 2);
  delete(outputFile);
  delete('bidspm.bib');

end

function value = partialsPapth()
  value = fullfile(returnRootDir(), 'src', 'reports', 'partials');
end
