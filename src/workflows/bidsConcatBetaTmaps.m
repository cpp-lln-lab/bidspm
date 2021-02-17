% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function bidsConcatBetaTmaps(opt, funcFWHM, deleteIndBeta, deleteIndTmaps)
  %
  % Make 4D images of beta and t-maps for the MVPA. ::
  %
  %   concatBetaImgTmaps(funcFWHM, opt, [deleteIndBeta = true,] [deleteIndTmaps = true])
  %
  % :param opt: options structure
  % :type opt: structure
  % :param funcFWHM: smoothing (FWHM) applied to the the normalized EPI
  % :type funcFWHM: (scalar)
  % :param deleteIndBeta: decide to delete beta-maps
  % :type funcFWHM: (boolean)
  % :param deleteIndTmaps: decide to delete t-maps
  % :type funcFWHM: (boolean)
  %

  % delete individual Beta and tmaps
  if nargin < 3
    deleteIndBeta = 1;
    deleteIndTmaps = 1;
  end

  [~, opt, group] = setUpWorkflow(opt, 'merge beta images and t-maps');

  % clear previous matlabbatch and files
  matlabbatch = [];
  RT = 0;

  %% Loop through the groups, subjects
  for iGroup = 1:length(group)

    for iSub = 1:group(iGroup).numSub

      subID = group(iGroup).subNumber{iSub};

      ffxDir = getFFXdir(subID, funcFWHM, opt);

      contrasts = specifyContrasts(ffxDir, opt.taskName, opt);

      beta_maps = cell(length(contrasts), 1);
      t_maps = cell(length(contrasts), 1);

      % path to beta and t-map files.
      for iContrast = 1:length(beta_maps)
        % Note that the betas are created from the idx (Beta_idx(iBeta))
        fileName = sprintf('beta_%04d.nii', find(contrasts(iContrast).C));
        fileName = validationInputFile(ffxDir, fileName);
        beta_maps{iContrast, 1} = [fileName, ',1'];

        % while the contrastes (t-maps) are not from the index. They were created
        fileName = sprintf('spmT_%04d.nii', iContrast);
        fileName = validationInputFile(ffxDir, fileName);
        t_maps{iContrast, 1} = [fileName, ',1'];
      end

      % beta maps
      outputName = ['4D_beta_', num2str(funcFWHM), '.nii'];
      
      matlabbatch = [];
      matlabbatch = setBatch3Dto4D(matlabbatch, beta_maps, RT, outputName);

      % t-maps
      outputName = ['4D_t_maps_', num2str(funcFWHM), '.nii'];
      
      matlabbatch = setBatch3Dto4D(matlabbatch, t_maps, RT, outputName);

      saveAndRunWorkflow(matlabbatch, 'concat_betaImg_tMaps', opt, subID);

      removeBetaImgTmaps(t_maps, deleteIndBeta, deleteIndTmaps, ffxDir);

    end
  end

end

function removeBetaImgTmaps(t_maps, deleteIndBeta, deleteIndTmaps, ffxDir)

  % delete maps
  if deleteIndBeta

    % delete all individual beta maps
    fprintf('Deleting individual beta-maps ...  ');
    delete(fullfile(ffxDir, ['beta_*', '.nii']));
    fprintf('Done. \n\n\n ');

  end

  if  deleteIndTmaps

    % delete all individual con maps
    fprintf('Deleting individual con maps ...  ');
    for iCon = 1:length(t_maps)
      delete(fullfile(ffxDir, ['con_', sprintf('%04d', iCon), '.nii']));
    end
    fprintf('Done. \n\n\n ');

    % delete all individual t-maps
    fprintf('Deleting individual t-maps ...  ');
    for iTmap = 1:length(t_maps)
      delete(t_maps{iTmap}(1:end - 2));
    end
    fprintf('Done. \n\n\n ');
  end

end
