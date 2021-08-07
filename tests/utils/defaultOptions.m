function expectedOptions = defaultOptions(taskName)
  %
  % (C) Copyright 2021 CPP_SPM developers

  expectedOptions.sliceOrder = [];
  expectedOptions.STC_referenceSlice = [];

  expectedOptions.dataDir = '';
  expectedOptions.derivativesDir = '';
  expectedOptions.dir = struct('raw', '', ...
                               'derivatives', '');

  expectedOptions.funcVoxelDims = [];

  expectedOptions.groups = {''};
  expectedOptions.subjects = {[]};

  expectedOptions.query = struct([]);

  expectedOptions.space = 'MNI';

  expectedOptions.anatReference.type = 'T1w';
  expectedOptions.anatReference.session = [];

  expectedOptions.skullstrip.threshold = 0.75;
  expectedOptions.skullstrip.mean = false;

  expectedOptions.realign.useUnwarp = true;
  expectedOptions.useFieldmaps = true;

  expectedOptions.taskName = '';

  expectedOptions.zeropad = 2;

  expectedOptions.contrastList = {};

  expectedOptions.QA.glm.do = true;
  expectedOptions.QA.func.carpetPlot = true;
  expectedOptions.QA.func.Motion = 'on';
  expectedOptions.QA.func.FD = 'on';
  expectedOptions.QA.func.Voltera = 'on';
  expectedOptions.QA.func.Globals = 'on';
  expectedOptions.QA.func.Movie = 'on';
  expectedOptions.QA.func.Basics = 'on';

  expectedOptions.glm.roibased.do = false;

  expectedOptions.model.file = '';
  expectedOptions.model.hrfDerivatives = [0 0];

  expectedOptions.result.Steps = returnDefaultResultsStructure();

  expectedOptions.parallelize.do = false;
  expectedOptions.parallelize.nbWorkers = 3;
  expectedOptions.parallelize.killOnExit = false;

  if nargin > 0
    expectedOptions.taskName = taskName;
  end

  %  Options for toolboxes
  global ALI_TOOLBOX_PRESENT

  checkToolbox('ALI');
  if ALI_TOOLBOX_PRESENT
    expectedOptions = setFields(expectedOptions, ALI_my_defaults());
  end

  expectedOptions = orderfields(expectedOptions);

  expectedOptions = setStatsDir(expectedOptions);

end
