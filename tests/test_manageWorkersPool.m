function test_suite = test_manageWorkersPool %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_manageWorkersPoolBasic()

  opt.parallelize.do = true;
  opt.parallelize.nbWorkers = 3;
  opt.parallelize.killOnExit = true;

  matlabVer = version('-release');

  manageWorkersPool('close', opt);

  manageWorkersPool('open', opt);

  if ~isOctave()
    if str2double(matlabVer(1:4)) > 2013

      pool = gcp('nocreate');
      nbWorkers = pool.NumWorkers;

    else
      nbWorkers = matlabpool('size'); %#ok<DPOOL>

    end

    manageWorkersPool('close', opt);

    assertEqual(nbWorkers, opt.parallelize.nbWorkers);

  end

end

function test_manageWorkersPoolNoParallel()

  opt.parallelize.do = false;
  opt.parallelize.nbWorkers = 3;
  opt.parallelize.killOnExit = true;

  matlabVer = version('-release');

  manageWorkersPool('close', opt);

  manageWorkersPool('open', opt);

  if ~isOctave()
    if str2double(matlabVer(1:4)) > 2013

      pool = gcp('nocreate');
      nbWorkers = pool.NumWorkers;

    else
      nbWorkers = matlabpool('size'); %#ok<DPOOL>

    end

    manageWorkersPool('close', opt);

    assertEqual(nbWorkers, 1);

  end

end
