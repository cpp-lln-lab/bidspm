function test_suite = test_getRegressorIdx %#ok<*STOUT>
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getRegressorIdx_basic()

  SPM.xX.name = {'Sn(1) famous_1*bf(1)'
                 'Sn(1) famous_1*bf(2)'
                 'Sn(1) famous_1*bf(3)'
                 'Sn(1) famous_2*bf(1)'
                 'Sn(1) famous_2*bf(2)'
                 'Sn(1) famous_2*bf(3)'
                 'Sn(1) unfamiliar_1*bf(1)'
                 'Sn(1) unfamiliar_1*bf(2)'
                 'Sn(1) unfamiliar_1*bf(3)'
                 'Sn(1) unfamiliar_2*bf(1)'
                 'Sn(1) unfamiliar_2*bf(2)'
                 'Sn(1) unfamiliar_2*bf(3)'
                 'Sn(1) trans_x'
                 'Sn(1) trans_y'
                 'Sn(1) trans_z'
                 'Sn(1) rot_x'
                 'Sn(1) rot_y'
                 'Sn(1) rot_z'
                 'Sn(1) constant'}';

  %% convolved
  [cdtName, regIdx, status] = getRegressorIdx('trial_type.famous_1', SPM);

  assertEqual(cdtName, 'famous_1');

  expected =  false(numel(SPM.xX.name), 1);
  expected(1) = true;
  assertEqual(regIdx, expected);

  assertEqual(status, true);

  %% non convolved
  [cdtName, regIdx, status] = getRegressorIdx('trans_x', SPM);

  assertEqual(cdtName, 'trans_x');

  expected =  false(numel(SPM.xX.name), 1);
  expected(13) = true;
  assertEqual(regIdx, expected);

  assertEqual(status, true);

  %% missing
  assertWarning(@()getRegressorIdx('foo', SPM), 'getRegressorIdx:missingRegressor');

  sts = warning('QUERY', 'getRegressorIdx:missingRegressor');
  if strcmp(sts.state, 'on')
    warning('OFF', 'getRegressorIdx:missingRegressor');
  end

  [cdtName, regIdx, status] = getRegressorIdx('foo', SPM);

  assertEqual(cdtName, 'foo');

  expected =  false(numel(SPM.xX.name), 1);
  assertEqual(regIdx, expected);

  assertEqual(status, false);

end
