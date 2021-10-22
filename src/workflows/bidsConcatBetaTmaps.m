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
  % When concatenating betamaps:
  %
  % Ensures that there is only 1 image per "contrast".
  % Creates a tsv that lists the content of the 4D image.
  % This TSV is in the subject level GLM folder where the beta map came from.
  % This TSV file is named ``sub-subLabel_task-taskName_space-space_labelfold.tsv``.
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 3
    deleteIndBeta = 1;
    deleteIndTmaps = 1;
  end

  [~, opt] = setUpWorkflow(opt, 'merge beta images and t-maps');

  RT = 0;

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    ffxDir = getFFXdir(subLabel, funcFWHM, opt);

    load(fullfile(ffxDir, 'SPM.mat'));

    model = spm_jsonread(opt.model.file);
    
    contrasts = specifyContrasts(SPM, opt.taskName, model);

    beta_maps = cell(length(contrasts), 1);
    t_maps = cell(length(contrasts), 1);

    % path to beta and t-map files.
    for iContrast = 1:length(beta_maps)

      betasIndices = find(contrasts(iContrast).C);

      if numel(betasIndices) > 1
        error('Supposed to concatenate one beta image per contrast.');
      end

      % for this beta iamge we identify
      % - which run it came from
      % - the exact condition name stored in the SPM.mat
      % so they can be saved in a tsv for for "label" and "fold" for MVPA
      tmp = cat(1, SPM.Sess(:).col) == betasIndices;
      runs(iContrast, 1) = find(any(tmp, 2));

      tmp = SPM.xX.name{betasIndices};
      parts = strsplit(tmp, ' ');
      conditions{iContrast, 1} = strjoin(parts(2:end), ' ');

      fileName = sprintf('beta_%04d.nii', betasIndices);
      fileName = validationInputFile(ffxDir, fileName);
      beta_maps{iContrast, 1} = [fileName, ',1'];

      % while the contrastes (t-maps) are not from the index. They were created
      fileName = sprintf('spmT_%04d.nii', iContrast);
      fileName = validationInputFile(ffxDir, fileName);
      t_maps{iContrast, 1} = [fileName, ',1'];

    end

    % tsv
    nameStructure = struct( ...
                           'ext', '.tsv', ...
                           'suffix', 'labelfold', ...
                           'entities', struct('sub', subLabel, ...
                                             'task', opt.taskName, ...
                                             'space', opt.space));
    tsvName = bids.create_filename(nameStructure);

    tsvContent = struct('folds', runs, 'labels', {conditions});

    spm_save(fullfile(ffxDir, tsvName), tsvContent);

    % beta maps
    outputName = ['4D_beta_', num2str(funcFWHM), '.nii'];

    matlabbatch = {};
    matlabbatch = setBatch3Dto4D(matlabbatch, beta_maps, RT, outputName);

    % t-maps
    outputName = ['4D_t_maps_', num2str(funcFWHM), '.nii'];

    matlabbatch = setBatch3Dto4D(matlabbatch, t_maps, RT, outputName);

    saveAndRunWorkflow(matlabbatch, 'concat_betaImg_tMaps', opt, subLabel);

    removeBetaImgTmaps(t_maps, deleteIndBeta, deleteIndTmaps, ffxDir);

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
