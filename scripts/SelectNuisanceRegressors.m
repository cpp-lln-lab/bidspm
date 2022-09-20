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

%%
function calc_reg_nuis_fmriprep (w, num_sess)
  %% Pour la session/run num_sess : extraction des regresseurs de nuisance a partir des outputs de fmriprep

  if strcmp(w.type_run, 'RUNS') == 1
    fic_json = spm_select('FPList', fullfile(w.main_dir, w.subName, 'func'), ['^' w.subName '.*' w.sessions{num_sess} '.*confounds_regressors\.json$']);
    fic_tsv = spm_select('FPList', fullfile(w.main_dir, w.subName, 'func'), ['^' w.subName '.*' w.sessions{num_sess} '.*confounds_regressors\.tsv$']);

  elseif strcmp(w.type_run, 'PUFF')

    %%%% before changing name 'localizerPUFF' to 'LocalizerPuff'
    %     if strcmp(w.subName,'sub-pilote1')==1
    %         fic_json = spm_select('FPList',   fullfile(w.main_dir, w.subName, 'func'), ['^' w.subName '.*' 'LocalizerPUFF' '.*confounds_regressors\.json$']);
    %         fic_tsv = spm_select('FPList',  fullfile(w.main_dir, w.subName, 'func'), ['^' w.subName '.*' 'localizerPUFF' '.*confounds_regressors\.tsv$']);
    %     else
    fic_json = spm_select('FPList',   fullfile(w.main_dir, w.subName, 'func'), ['^' w.subName '.*' 'LocalizerPuff' '.*confounds_regressors\.json$']);
    fic_tsv = spm_select('FPList',  fullfile(w.main_dir, w.subName, 'func'), ['^' w.subName '.*' 'LocalizerPuff' '.*confounds_regressors\.tsv$']);
    %     end

  elseif strcmp(w.type_run, 'MT')
    fic_json = spm_select('FPList',  fullfile(w.main_dir, w.subName, 'func'), ['^' w.subName '.*' 'MT' '.*confounds_regressors\.json$']);
    fic_tsv = spm_select('FPList',  fullfile(w.main_dir, w.subName, 'func'), ['^' w.subName '.*' 'MT' '.*confounds_regressors\.tsv$']);
  end

  info_json = jsonread(fic_json);
  data_tsv = bids.util.tsvread(fic_tsv);

  nb_reg_tis = zeros(1, length(w.tissu_names));
  names_reg = [];
  reg_nuis = [];

  i = 1;
  encore = 1;
  data_tsv_names = fieldnames(data_tsv);

  while i <= length(data_tsv_names) && encore
    if ~isempty(strfind(data_tsv_names{i}, 'a_comp_cor_'))
      for ii = 1:length(w.tissu_names)
        if (strcmp(info_json.(data_tsv_names{i}).Mask, w.tissu_names(ii))) && (nb_reg_tis(ii) < w.nb_reg_tissu(ii))
          names_reg = [names_reg {data_tsv_names{i}}];
          reg_nuis = [reg_nuis, data_tsv.(data_tsv_names{i})];
          nb_reg_tis(ii) = nb_reg_tis(ii) + 1;
        end
      end
    end
    encore = 0;
    for ii = 1:length(w.tissu_names)
      if nb_reg_tis(ii) < w.nb_reg_tissu(ii)
        encore = 1;
      end
    end
    i = i + 1;
  end

  for ii = 1:length(w.reg_supp_mvt)
    names_reg = [names_reg w.reg_supp_mvt(ii)];
    if iscell(data_tsv.(w.reg_supp_mvt{ii}))    % colonne lue comme cell de strings et non comme vecteur de double a cause du n/A de la 1ere ligne
      data_tmp = [];
      data_tsv.(w.reg_supp_mvt{ii}){1} = '0.0'; % On remplace 'n/a' par '0.0'
      for jj = 1:length(data_tsv.(w.reg_supp_mvt{ii}))
        data_tmp = [data_tmp; str2double(data_tsv.(w.reg_supp_mvt{ii}){jj})];
      end
      reg_nuis = [reg_nuis, data_tmp];
    else
      reg_nuis = [reg_nuis, data_tsv.(w.reg_supp_mvt{ii})];
    end
  end

  names_reg_included = append('toinclude_', names_reg);

  data_tsv_new = data_tsv;

  %%%% add the included names & regressors at the end of the tsv structure
  for i = 1:length(names_reg_included)
    data_tsv_new.(names_reg_included{i}) = reg_nuis(:, i);
  end

  % bids.util.tsvwrite(fullfile([fic_tsv(1:end-4) 'TEST.tsv']), data_tsv_new); %% for testing
  % bids.util.tsvwrite(fullfile(fic_tsv), data_tsv_new); %%% writes directly the .tsv file

end
