function test_suite = test_checkOptions %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_checkOptionsBasic()

  opt.taskName = 'testTask';
  opt = checkOptions(opt);

  expectedOptions = defaultOptions();
  expectedOptions.taskName = 'testTask';

  assertEqual(opt, expectedOptions);

end

function test_checkOptionsDoNotOverwrite()

  opt.funcVoxelDims = [1 1 1];
  opt.someExtraField = 'test';
  opt.taskName = 'testTask';

  opt = checkOptions(opt);

  assertEqual(opt.funcVoxelDims, [1 1 1]);
  assertEqual(opt.someExtraField, 'test');

end

function test_checkOptionsErrorTask()

  opt.taskName = [];

  assertExceptionThrown( ...
                        @()checkOptions(opt), ...
                        'checkOptions:noTask');

end

function test_checkOptionsErrorGroup()

  opt.groups = {1};
  opt.taskName = 'testTask';

  assertExceptionThrown( ...
                        @()checkOptions(opt), ...
                        'checkOptions:groupNotString');

end

function test_checkOptionsErrorRefSlice()

  opt.STC_referenceSlice = [1:10];
  opt.taskName = 'testTask';

  assertExceptionThrown( ...
                        @()checkOptions(opt), ...
                        'checkOptions:refSliceNotScalar');

end

function test_checkOptionsErrorVoxDim()

  opt.funcVoxelDims = [1:10];
  opt.taskName = 'testTask';

  assertExceptionThrown( ...
                        @()checkOptions(opt), ...
                        'checkOptions:voxDim');

end

function expectedOptions = defaultOptions()

  expectedOptions.sliceOrder = [];
  expectedOptions.STC_referenceSlice = [];

  expectedOptions.dataDir = '';
  expectedOptions.derivativesDir = '';

  expectedOptions.funcVoxelDims = [];

  expectedOptions.groups = {''};
  expectedOptions.subjects = {[]};

  expectedOptions.space = 'MNI';

  expectedOptions.anatReference.type = 'T1w';
  expectedOptions.anatReference.session = [];

  expectedOptions.skullstrip.threshold = 0.75;

  expectedOptions.realign.useUnwarp = true;
  expectedOptions.useFieldmaps = true;

  expectedOptions.taskName = '';

  expectedOptions.zeropad = 2;

  expectedOptions.contrastList = {};
  expectedOptions.model.file = '';
  expectedOptions.model.hrfDerivatives = [0 0];

  expectedOptions.result.Steps = returnDefaultResultsStructureBasic();

  expectedOptions.parallelize.do = false;
  expectedOptions.parallelize.nbWorkers = 3;
  expectedOptions.parallelize.killOnExit = true;

  expectedOptions = orderfields(expectedOptions);

end
