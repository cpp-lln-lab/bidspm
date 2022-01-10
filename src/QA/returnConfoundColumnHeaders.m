function headers = returnConfoundColumnHeaders(opt)
  %
  %
  % USAGE::
  %
  %   headers = returnConfoundColumnHeaders(opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % (C) Copyright 2020 CPP_SPM developers

  if strcmp(opt.QA.func.Voltera, 'on')
    headers = {'trans_x'
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
  else
    % TODO BUG from spm_up that does not return FD, RMS and global signal when
    % voltera 'on'
    headers = {'trans_x'
               'trans_y'
               'trans_z'
               'rot_x'
               'rot_y'
               'rot_z'};

    if strcmp(opt.QA.func.FD, 'on')
      headers{end + 1, 1} = 'framewise_displacement';
      headers{end + 1, 1} = 'root_mean_square';
    end
    if strcmp(opt.QA.func.Globals, 'on')
      headers{end + 1, 1} = 'global_signal';
    end

  end

end
