function test_suite = test_getData %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getDataBasic()

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.taskName = 'vismotion';

  %% Only get anat metadata
  opt.groups = {''};

  opt.subjects = {'01'};

  [~, opt] = getData(opt, [], 'T1w');

  assert(isequal(opt.metadata.RepetitionTime, 2.3));

end

function test_getDataErrorTask()
  % Small test to ensure that getData returns what we asked for

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.taskName = 'testTask';
  opt.zeropad = 2;

  %% Get all groups all subjects
  opt.groups = {''};
  opt.subjects = {[]};

  assertExceptionThrown( ...
                        @()getData(opt), ...
                        'getData:noMatchingTask');

end
