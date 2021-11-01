function bidsConcatBetaTmaps(opt, deleteIndBeta, deleteIndTmaps)
  %
  % Make 4D images of beta and t-maps for the MVPA.
  %
  % USAGE::
  %
  %   concatBetaImgTmaps(opt, [deleteIndBeta = true,] [deleteIndTmaps = true])
  %
  % :param opt: options structure
  % :type opt: structure
  % :param deleteIndBeta: decide to delete beta-maps
  % :type deleteIndBeta: (boolean)
  % :param deleteIndTmaps: decide to delete t-maps
  % :type deleteIndTmaps: (boolean)
  %
  % When concatenating betamaps:
  %
  % Ensures that there is only 1 image per "contrast".
  % Creates a tsv that lists the content of the 4D image.
  % This TSV is in the subject level GLM folder where the beta map came from.
  % This TSV file is named ``sub-subLabel_task-taskName_space-space_labelfold.tsv``.
  %
  % (C) Copyright 2019 CPP_SPM developers

  [~, opt] = setUpWorkflow(opt, 'merge beta images and t-maps');

  if nargin < 3
    deleteIndBeta = true;
    deleteIndTmaps = true;
  end
  if opt.dryRun
    deleteIndBeta = false;
    deleteIndTmaps = false;
  end

  RT = 0;

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    ffxDir = getFFXdir(subLabel, opt);

    load(fullfile(ffxDir, 'SPM.mat'));

    model = spm_jsonread(opt.model.file);

    contrasts = specifyContrasts(SPM, opt.taskName, model);

    betaMaps = cell(length(contrasts), 1);
    tMaps = cell(length(contrasts), 1);

    % path to beta and t-map files.

    fprintf(1, '\nConcatenating the following contrasts:');
    for iContrast = 1:length(beta_maps)

      fprintf(1, '\n\t%s', contrasts(iContrast).name);
      betasIndices = find(contrasts(iContrast).C);

      if numel(betasIndices) > 1
        error('Supposed to concatenate one beta image per contrast.');
      end

      % for this beta image we identify
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
      betaMaps{iContrast, 1} = [fileName, ',1'];

      fileName = sprintf('spmT_%04d.nii', iContrast);
      fileName = validationInputFile(ffxDir, fileName);
      tMaps{iContrast, 1} = [fileName, ',1'];

    end

    % tsv
    nameStructure = struct( ...
                           'ext', '.tsv', ...
                           'suffix', 'labelfold', ...
                           'use_schema', false, ...
                           'entities' struct('sub', subLabel, ...
                                             'task', opt.taskName, ...
                                             'space', opt.space));

    tsvName = bids.create_filename(nameStructure);

    tsvContent = struct('folds', runs, 'labels', {conditions});

    spm_save(fullfile(ffxDir, tsvName), tsvContent);

    % TODO in the dev branch make those output filenames "BIDS derivatives" compliant
    % beta maps
    outputName = ['4D_beta_', num2str(opt.fwhm.func), '.nii'];

    matlabbatch = {};
    matlabbatch = setBatch3Dto4D(matlabbatch, betaMaps, RT, outputName);

    % t-maps
    outputName = ['4D_tMaps_', num2str(opt.fwhm.func), '.nii'];

    matlabbatch = setBatch3Dto4D(matlabbatch, tMaps, RT, outputName);

    % TODO temporary: remove on dev branch
    if ~opt.dryRun
      saveAndRunWorkflow(matlabbatch, 'concat_betaImg_tMaps', opt, subLabel);
    end

    removeBetaImgTmaps(tMaps, deleteIndBeta, deleteIndTmaps, ffxDir);

  end

end

function removeBetaImgTmaps(tMaps, deleteIndBeta, deleteIndTmaps, ffxDir)

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
    for iCon = 1:length(tMaps)
      delete(fullfile(ffxDir, ['con_', sprintf('%04d', iCon), '.nii']));
    end
    fprintf('Done. \n\n\n ');

    % delete all individual t-maps
    fprintf('Deleting individual t-maps ...  ');
    for iTmap = 1:length(tMaps)
      delete(tMaps{iTmap}(1:end - 2));
    end
    fprintf('Done. \n\n\n ');

  end

end
