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

  useUnwarp = {true, false};
  space = { {'individual'}, ...
           {'individual', 'IXI549Space'} };

  for iUseUnwarp = 1:2
    for iSpace = 1:numel(space)
      for fwhm = [0, 6]
        for dummy_scans = [0, 4]

          printTestParameters(mfilename(), ...
                              dummy_scans, ...
                              space{iSpace}, ...
                              useUnwarp{iUseUnwarp}, ...
                              fwhm);

          outputPath = tempName();

          opt = setOptions('MoAE-preproc');

          opt.stc.referenceSlice = 32;

          opt.dummy_scans = dummy_scans;
          opt.space = space{iSpace};
          opt.realign.useUnwarp = useUnwarp{iUseUnwarp};
          opt.fwhm.func = fwhm;

          outputFile = boilerplate(opt, ...
                                   'outputPath', outputPath, ...
                                   'pipelineType', 'preproc', ...
                                   'partialsPath', partialsPath(), ...
                                   'verbosity', 0);

          assertEqual(exist(outputFile, 'file'), 2);

        end

      end

    end

  end

end

function test_boilerplate_spatial_subject_glm()

  desginTypes = {'block', 'event'};

  for fwhm = [0, 6]
    for i = 1:numel(desginTypes)

      outputPath = tempName();

      opt = setOptions('facerep');

      opt.fwhm.contrast = fwhm;

      opt.designType = desginTypes{i};

      outputFile = boilerplate(opt, ...
                               'outputPath', outputPath, ...
                               'pipelineType', 'stats', ...
                               'partialsPath', partialsPath(), ...
                               'verbosity', 0);

      assertEqual(exist(outputFile, 'file'), 2);

    end
  end

end

function value = partialsPath()
  value = fullfile(returnRootDir(), 'src', 'reports', 'partials');
end

function pth = tempName()
  pth = tempname();
  mkdir(pth);
end
