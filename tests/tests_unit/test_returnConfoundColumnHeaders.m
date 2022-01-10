function test_suite = test_returnConfoundColumnHeaders %#ok<*STOUT>
  %
  % (C) Copyright 2021 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_returnConfoundColumnHeaders_voltera()

  opt.QA.func.Voltera = 'on';

  headers = returnConfoundColumnHeaders(opt);

  expected = {'trans_x'
              'trans_y'
              'trans_z'
              'rot_x'
              'rot_y'
              'rot_z'
              'trans_x_derivative1'
              'trans_y_derivative1'
              'trans_z_derivative1'
              'rot_x_derivative1'
              'rot_y_derivative1'
              'rot_z_derivative1'
              'trans_x_power2'
              'trans_y_power2'
              'trans_z_power2'
              'rot_x_power2'
              'rot_y_power2'
              'rot_z_power2'
              'trans_x_derivative1_power2'
              'trans_y_derivative1_power2'
              'trans_z_derivative1_power2'
              'rot_x_derivative1_power2'
              'rot_y_derivative1_power2'
              'rot_z_derivative1_power2'
             };

  assertEqual(headers, expected);

end

function test_returnConfoundColumnHeaders_motion()

  opt.QA.func.Voltera = 'off';
  opt.QA.func.FD = 'off';
  opt.QA.func.Globals = 'off';

  headers = returnConfoundColumnHeaders(opt);

  expected = {'trans_x'
              'trans_y'
              'trans_z'
              'rot_x'
              'rot_y'
              'rot_z'
             };
end

function test_returnConfoundColumnHeaders_FD_globals()

  opt.QA.func.Voltera = 'off';
  opt.QA.func.FD = 'on';
  opt.QA.func.Globals = 'on';

  headers = returnConfoundColumnHeaders(opt);

  expected = {'trans_x'
              'trans_y'
              'trans_z'
              'rot_x'
              'rot_y'
              'rot_z'
              'framewise_displacement'
              'root_mean_square'
              'global_signal'
             };
end

function test_returnConfoundColumnHeaders_globals()

  opt.QA.func.Voltera = 'off';
  opt.QA.func.FD = 'off';
  opt.QA.func.Globals = 'on';

  headers = returnConfoundColumnHeaders(opt);

  expected = {'trans_x'
              'trans_y'
              'trans_z'
              'rot_x'
              'rot_y'
              'rot_z'
              'global_signal'
             };
end

function test_returnConfoundColumnHeaders_FD()

  opt.QA.func.Voltera = 'off';
  opt.QA.func.FD = 'on';
  opt.QA.func.Globals = 'off';

  headers = returnConfoundColumnHeaders(opt);

  expected = {'trans_x'
              'trans_y'
              'trans_z'
              'rot_x'
              'rot_y'
              'rot_z'
              'framewise_displacement'
              'root_mean_square'
             };
end
