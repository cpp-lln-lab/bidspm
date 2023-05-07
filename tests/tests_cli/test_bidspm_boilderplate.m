function test_suite = test_bidspm_boilderplate %#ok<*STOUT>

  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_boilerplate_stats_only()

  if ~bids.internal.is_github_ci()
    % when not in CI the octache partials are not in the right place
    return
  end

  outputPath = tmpName();

  opt = setOptions('MoAE');

  bidspm(opt.dir.raw, outputPath, 'subject', ...
         'action', 'stats', ...
         'preproc_dir', opt.dir.preproc, ...
         'model_file',  opt.model.file, ...
         'boilerplate_only', true, ...
         'verbosity', 0, ...
         'fwhm', 6);

  assertEqual(exist(fullfile(outputPath, ...
                             'bidspm-stats', ...
                             'reports', ...
                             'stats_model-auditory_citation.md'), ...
                    'file'), ...
              2);

end

function test_boilerplate_preproc_only()

  if ~bids.internal.is_github_ci()
    % when not in CI the octache partials are not in the right place
    return
  end
  outputPath = tmpName();

  opt = setOptions('MoAE');

  bidspm(opt.dir.raw, outputPath, 'subject', ...
         'action', 'preprocess', ...
         'boilerplate_only', true, ...
         'task', {'auditory'}, ...
         'verbosity', 0, ...
         'fwhm', 6);

  assertEqual(exist(fullfile(outputPath, ...
                             'bidspm-preproc', ...
                             'reports', ...
                             'preprocess_citation.md'), ...
                    'file'), ...
              2);
end

function pth = tmpName()
  pth = tempname();
  mkdir(pth);
end
