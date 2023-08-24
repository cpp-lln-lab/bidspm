function test_suite = test_initBids %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_initBids_basic()

  % GIVEN
  opt.dir.output = fullfile(tempName(), 'foo');
  opt.pipeline.name = 'bidspm';
  opt.pipeline.type = '';
  opt.verbosity = 0;

  % WHEN
  initBids(opt);

  assertEqual(exist(fullfile(opt.dir.output, 'LICENSE'), 'file'), 2);
  assertEqual(exist(fullfile(opt.dir.output, 'README.md'), 'file'), 2);
  assertEqual(exist(fullfile(opt.dir.output, '.gitignore'), 'file'), 2);

  content = bids.util.jsondecode(fullfile(opt.dir.output, 'dataset_description.json'));

  assertEqual(content.Name, '');
  assertEqual(content.License, 'CC0');
  assertEqual(content.GeneratedBy.Name, 'bidspm');
  assertEqual(content.GeneratedBy.Description, '');

end

function test_initBids_name_description()

  % GIVEN
  opt.dir.output = fullfile(tempName(), 'foo');
  opt.pipeline.name = 'bidspm';
  opt.pipeline.type = 'stats';
  opt.verbosity = 0;

  % WHEN
  initBids(opt, 'description', 'subject level stats');

  content = bids.util.jsondecode(fullfile(opt.dir.output, 'dataset_description.json'));

  assertEqual(content.Name, 'subject level stats');
  assertEqual(content.GeneratedBy.Name, 'bidspm-stats');
  assertEqual(content.GeneratedBy.Description, 'subject level stats');

end

function test_initBids_force()

  % GIVEN
  opt.dir.output = fullfile(tempName(), 'foo');
  opt.pipeline.name = 'bidspm';
  opt.pipeline.type = 'stats';
  opt.verbosity = 0;

  % WHEN
  initBids(opt, 'description', 'subject level stats');

  initBids(opt, 'description', '');
  content = bids.util.jsondecode(fullfile(opt.dir.output, 'dataset_description.json'));
  assertEqual(content.GeneratedBy.Description, 'subject level stats');

  initBids(opt, 'description', '', 'force', true);
  content = bids.util.jsondecode(fullfile(opt.dir.output, 'dataset_description.json'));
  assertEqual(content.GeneratedBy.Description, '');

end
