function test_suite = test_computeDesignEfficiency %#ok<*STOUT>
  %
  % (C) Copyright 2021 CPP_SPM developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_computeDesignEfficiency_vislocalizer()

  close all;

  opt = setOptions('vismotion', '01');

  BIDS = bids.layout(opt.dir.input);

  metadata = bids.query(BIDS, 'metadata', ...
                        'sub', opt.subjects, ...
                        'task', opt.taskName, ...
                        'suffix', 'bold');

  opt.TR = metadata{1}.RepetitionTime;

  eventsFile = bids.query(BIDS, 'data', ...
                          'sub', opt.subjects, ...
                          'task', opt.taskName, ...
                          'suffix', 'events');

  e = computeDesignEfficiency(eventsFile{1}, opt);

  assertElementsAlmostEqual(e, [0.005 0.005 0.001], 'absolute', 1e-3);

end

function test_computeDesignEfficiency_block_design

  %% create stats model JSON
  json = createEmptyStatsModel();
  runStepIdx = 1;
  json.Steps{runStepIdx}.Model.X = {'trial_type.cdt_A', 'trial_type.cdt_B'};
  json.Steps{runStepIdx}.AutoContrasts = {'trial_type.cdt_A', 'trial_type.cdt_B'};

  contrast = struct('type', 't', ...
                    'Name', 'A_gt_B', ...
                    'weights', [1, -1], ...
                    'ConditionList', {{'trial_type.cdt_A', 'trial_type.cdt_B'}});

  json.Steps{runStepIdx}.Contrasts = contrast;

  bids.util.jsonwrite('smdl.json', json);

  %% create events TSV file
  conditions = {'cdt_A', 'cdt_B'};
  IBI = 5;
  ISI = 0.1;
  stimDuration = 1.5;
  stimPerBlock = 12;
  nbBlocks = 10;

  trial_type = {};
  onset = [];
  duration = [];

  time = 0;

  for iBlock = 1:nbBlocks
    for cdt = 1:numel(conditions)
      for iTrial = 1:stimPerBlock
        trial_type{end + 1} = conditions{cdt};
        onset(end + 1) = time;
        duration(end + 1) = stimDuration;
        time = time + stimDuration + ISI;
      end
      time = time + IBI;
    end
  end

  tsv = struct('trial_type',  {trial_type}, 'onset', onset, 'duration', duration');

  bids.util.tsvwrite('events.tsv', tsv);

  opt = setTestCfg();
  opt.TR = 2;

  opt.model.file = fullfile(pwd, 'smdl.json');

  e = computeDesignEfficiency(fullfile(pwd, 'events.tsv'), opt);

  delete *.tsv;
  delete *.json;

end
