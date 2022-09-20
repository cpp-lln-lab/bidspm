function newTsvContent = selectConfoundsByVarianceExplained(tsvContent, metadata)

  w.tissu_names       = {'CSF', 'WM'}; % Tissus to regress out : 'WM','CSF' ou 'combined'
  w.nb_reg_tissu      = [12 12];  % Nb of PCA regressors per tissu
  
    w.nb_reg_mvt = 24; % 24 movement regressors at the end of the confounds (cf below)
  w.reg_supp_mvt      = {'trans_x', 'trans_x_derivative1', 'trans_x_derivative1_power2', 'trans_x_power2', ...
                         'trans_y', 'trans_y_derivative1', 'trans_y_derivative1_power2', 'trans_y_power2', ...
                         'trans_z', 'trans_z_derivative1', 'trans_z_power2', 'trans_z_derivative1_power2', ...
                         'rot_x', 'rot_x_derivative1', 'rot_x_power2', 'rot_x_derivative1_power2', ...
                         'rot_y', 'rot_y_derivative1', 'rot_y_power2', 'rot_y_derivative1_power2', ...
                         'rot_z', 'rot_z_derivative1', 'rot_z_power2', 'rot_z_derivative1_power2'};

  nb_reg_tis = zeros(1, length(w.tissu_names));
  names_reg = [];
  reg_nuis = [];

  i = 1;
  keepGoing = true;
  tsvContent_names = fieldnames(tsvContent);

  while i <= length(tsvContent_names) && keepGoing
      
    if ~isempty(strfind(tsvContent_names{i}, 'a_comp_cor_'))
      for ii = 1:length(w.tissu_names)
        if (strcmp(metadata.(tsvContent_names{i}).Mask, w.tissu_names(ii))) && ...
                (nb_reg_tis(ii) < w.nb_reg_tissu(ii))
          names_reg = [names_reg {tsvContent_names{i}}];
          reg_nuis = [reg_nuis, tsvContent.(tsvContent_names{i})];
          nb_reg_tis(ii) = nb_reg_tis(ii) + 1;
        end
      end
    end
    
    keepGoing = 0;
    for ii = 1:length(w.tissu_names)
      if nb_reg_tis(ii) < w.nb_reg_tissu(ii)
        keepGoing = 1;
      end
    end
    
    i = i + 1;
    
  end

  for ii = 1:length(w.reg_supp_mvt)
    names_reg = [names_reg w.reg_supp_mvt(ii)];
    % colonne lue comme cell de strings et non comme vecteur de double 
    % a cause du n/A de la 1ere ligne
    if iscell(tsvContent.(w.reg_supp_mvt{ii}))    
      data_tmp = [];
      % On remplace 'n/a' par '0.0'
      tsvContent.(w.reg_supp_mvt{ii}){1} = '0.0'; 
      for jj = 1:length(tsvContent.(w.reg_supp_mvt{ii}))
        data_tmp = [data_tmp; str2double(tsvContent.(w.reg_supp_mvt{ii}){jj})];
      end
      reg_nuis = [reg_nuis, data_tmp];
    else
      reg_nuis = [reg_nuis, tsvContent.(w.reg_supp_mvt{ii})];
    end
  end

  newTsvContent = tsvContent;

  %%%% add the included names & regressors at the end of the tsv structure
  for i = 1:length(names_reg)
    newTsvContent.(['toinclude_' names_reg{i}]) = reg_nuis(:, i);
  end

end