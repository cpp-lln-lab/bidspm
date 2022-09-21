function test_suite = test_initBids %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_initBids_basic()

  % GIVEN
  opt.dir.output = fullfile(pwd, 'foo');
  opt.pipeline.name = 'cpp_spm';
  opt.pipeline.type = '';
  opt.verbosity = 1;

  % WHEN
  initBids(opt);

  content = bids.util.jsondecode(fullfile(opt.dir.output, 'dataset_description.json'));

  assertEqual(content.Name, '');
  assertEqual(content.GeneratedBy.Name, 'cpp_spm');
  assertEqual(content.GeneratedBy.Description, '');

  cleanUp(opt);

end

function test_initBids_name_description()

  % GIVEN
  opt.dir.output = fullfile(pwd, 'foo');
  opt.pipeline.name = 'cpp_spm';
  opt.pipeline.type = 'stats';
  opt.verbosity = 1;

  % WHEN
  initBids(opt, 'description', 'subject level stats');

  content = bids.util.jsondecode(fullfile(opt.dir.output, 'dataset_description.json'));

  assertEqual(content.Name, 'subject level stats');
  assertEqual(content.GeneratedBy.Name, 'cpp_spm-stats');
  assertEqual(content.GeneratedBy.Description, 'subject level stats');

  cleanUp(opt);

end

function test_initBids_force()

  % GIVEN
  opt.dir.output = fullfile(pwd, 'foo');
  opt.pipeline.name = 'cpp_spm';
  opt.pipeline.type = 'stats';
  opt.verbosity = 1;

  % WHEN
  initBids(opt, 'description', 'subject level stats');

  initBids(opt, 'description', '');
  content = bids.util.jsondecode(fullfile(opt.dir.output, 'dataset_description.json'));
  assertEqual(content.GeneratedBy.Description, 'subject level stats');

  initBids(opt, 'description', '', 'force', true);
  content = bids.util.jsondecode(fullfile(opt.dir.output, 'dataset_description.json'));
  assertEqual(content.GeneratedBy.Description, '');

  cleanUp(opt);

end

function setUp()

end

function cleanUp(opt)
  rmdir(opt.dir.output, 's');
end
