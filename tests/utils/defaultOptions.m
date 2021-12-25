function expectedOptions = defaultOptions(taskName)
  %
  % (C) Copyright 2021 CPP_SPM developers

  expectedOptions.verbosity = 1;
  expectedOptions.dryRun = false;

  expectedOptions.pipeline.type =  'preproc';
  expectedOptions.pipeline.name = 'cpp_spm';

  expectedOptions.useBidsSchema = false;

  expectedOptions.fwhm.func = 6;
  expectedOptions.fwhm.contrast = 6;

  expectedOptions.stc.sliceOrder = [];
  expectedOptions.stc.referenceSlice = [];
  expectedOptions.stc.skip = false;

  expectedOptions.dir = struct('input', '', ...
                               'output', '', ...
                               'derivatives', '', ...
                               'raw', '', ...
                               'preproc', '', ...
                               'stats', '', ...
                               'jobs', '');

  expectedOptions.funcVoxelDims = [];

  expectedOptions.groups = {''};
  expectedOptions.subjects = {[]};

  expectedOptions.query.modality = {'anat', 'func'};

  expectedOptions.space = {'individual', 'MNI'};

  expectedOptions.anatReference.type = 'T1w';
  expectedOptions.anatReference.session = [];

  expectedOptions.segment.force = false;

  expectedOptions.skullstrip.threshold = 0.75;
  expectedOptions.skullstrip.mean = false;

  expectedOptions.realign.useUnwarp = true;
  expectedOptions.useFieldmaps = true;

  expectedOptions.taskName = {''};

  expectedOptions.zeropad = 2;

  expectedOptions.QA.glm.do = true;
  expectedOptions.QA.func.carpetPlot = true;
  expectedOptions.QA.func.Motion = 'on';
  expectedOptions.QA.func.FD = 'on';
  expectedOptions.QA.func.Voltera = 'on';
  expectedOptions.QA.func.Globals = 'on';
  expectedOptions.QA.func.Movie = 'on';
  expectedOptions.QA.func.Basics = 'on';

  expectedOptions.glm.roibased.do = false;
  expectedOptions.glm.maxNbVols = Inf;

  expectedOptions.model.file = '';
  expectedOptions.model.designOnly = false;
  expectedOptions.contrastList = {};

  expectedOptions.result.Nodes = returnDefaultResultsStructure();

  if nargin > 0
    expectedOptions.taskName = taskName;
  end
  if ~iscell(expectedOptions.taskName)
    expectedOptions.taskName = {expectedOptions.taskName};
  end

  %  Options for toolboxes
  global ALI_TOOLBOX_PRESENT

  checkToolbox('ALI');
  if ALI_TOOLBOX_PRESENT
    expectedOptions = setFields(expectedOptions, ALI_my_defaults());
  end

  expectedOptions = setFields(expectedOptions, rsHRF_my_defaults());

  expectedOptions = orderfields(expectedOptions);

  expectedOptions = setDirectories(expectedOptions);

end
