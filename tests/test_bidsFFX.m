% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsFFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsFfxMni()

  task = {'vislocalizer'}; % 'vismotion'

  for i = 1

    opt = setOptions(task{i});
    opt.space = {'MNI'};

    bidsFFX('specifyAndEstimate', opt);
    %   bidsFFX('contrasts', opt);
    %   bidsResults(opt);

  end

end

function test_bidsFfxIndividual()

  task = {'vislocalizer'}; % 'vismotion'

  for i = 1

    opt = setOptions(task{i});
    opt.space = {'individual'};

    bidsFFX('specifyAndEstimate', opt);
    %   bidsFFX('contrasts', opt);
    %   bidsResults(opt);

  end
end
