function SelectNuisanceRegressors(main_dir, all_subjects, type_of_runs)

  %%%% Takes the .tsv file with the nuisance regressors and adds a "included_"
  %%%% prefix to the regressors that are chosen. Regressors are chosen to
  %%%% explain most variance. nb_reg_tissu defines the number of regressors
  %%%% per tissu (here CSF & WM) is chosen. The N nb_reg_tissu will be picked and
  %%%% added to the movement regressors.

  w.main_dir = main_dir;
  w.all_subjects = all_subjects;
  w.type_of_runs = type_of_runs;
  w.all_subjects = append('sub-', all_subjects);

  %%% CONFOUNDS

  w.nb_reg_mvt = 24; % 24 movement regressors at the end of the confounds (cf below)
  w.reg_supp_mvt      = {'trans_x', 'trans_x_derivative1', 'trans_x_derivative1_power2', 'trans_x_power2', ...
                         'trans_y', 'trans_y_derivative1', 'trans_y_derivative1_power2', 'trans_y_power2', ...
                         'trans_z', 'trans_z_derivative1', 'trans_z_power2', 'trans_z_derivative1_power2', ...
                         'rot_x', 'rot_x_derivative1', 'rot_x_power2', 'rot_x_derivative1_power2', ...
                         'rot_y', 'rot_y_derivative1', 'rot_y_power2', 'rot_y_derivative1_power2', ...
                         'rot_z', 'rot_z_derivative1', 'rot_z_power2', 'rot_z_derivative1_power2'};
  % aCompCor fmiprep :
  w.tissu_names       = {'CSF', 'WM'}; % Tissus to regress out : 'WM','CSF' ou 'combined'
  w.nb_reg_tissu      = [12 12];  % Nb of PCA regressors per tissu

  %%% we do not take the global ones anymore (cf. fmriprep website)
  % w.reg_supp          = {'csf','white_matter'}; % supplemental regressors : mean of csf and white_matter

  %%%%%%

  for iS = 1:numel(w.all_subjects)

    w.subName = w.all_subjects{iS};

    for iTypeRun = 1:numel(w.type_of_runs)

      w.type_run = w.type_of_runs{iTypeRun};

      if strcmp(w.type_run, 'RUNS') == 1
        w.sessions  = {'run-01', 'run-02', 'run-03', 'run-04', 'run-05', 'run-06'};
        w.task = {'task-VisuoTact'};

      elseif  strcmp(w.type_run, 'MT') == 1
        w.sessions  = {''};
        w.task = {'task-LocalizerMT'};

      elseif  strcmp(w.type_run, 'PUFF') == 1
        w.sessions  = {''};
        w.task = {'task-LocalizerPuff'};

      end

    end

    for j = 1:numel(w.sessions)
      calc_reg_nuis_fmriprep (w, j);
    end

  end
end
