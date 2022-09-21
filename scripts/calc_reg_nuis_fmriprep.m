function calc_reg_nuis_fmriprep (w, num_sess)
  %% Pour la session/run num_sess : extraction des regresseurs de nuisance a partir des outputs de fmriprep

  fic_json = spm_select('FPList',  fullfile(w.main_dir, w.subName, 'func'), ['^' w.subName '.*' 'MT' '.*confounds_regressors\.json$']);
  fic_tsv = spm_select('FPList',  fullfile(w.main_dir, w.subName, 'func'), ['^' w.subName '.*' 'MT' '.*confounds_regressors\.tsv$']);

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
    % colonne lue comme cell de strings et non comme vecteur de double a cause du n/A de la 1ere ligne
    if iscell(data_tsv.(w.reg_supp_mvt{ii}))
      data_tmp = [];
      % On remplace 'n/a' par '0.0'
      data_tsv.(w.reg_supp_mvt{ii}){1} = '0.0';
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
