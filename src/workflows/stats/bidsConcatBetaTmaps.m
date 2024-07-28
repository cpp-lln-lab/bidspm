function bidsConcatBetaTmaps(opt, deleteTmaps)
  %
  % Make 4D images of beta and t-maps for the MVPA.
  %
  % USAGE::
  %
  %   bidsConcatBetaTmaps(opt, deleteIndTmaps)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :param deleteIndTmaps: decide to delete t-maps. Default to ``false``.
  % :type deleteIndTmaps: logical
  %
  % A valid BIDS stats model is required for this workflow:
  % this is because the beta images to concatenate
  % are those of the conditions mentioned in the ``DummyContrasts``
  % of the RUN level of the BIDS stats model.
  %
  % When concatenating betamaps:
  %
  % - Ensures that there is only 1 image per "contrast".
  % - Creates a tsv that lists the content of the 4D image.
  % - This TSV is in the subject level GLM folder where the beta map came from.
  % - This TSV file is named ``sub-subLabel_task-taskName_space-space_labelfold.tsv``.
  %

  % (C) Copyright 2019 bidspm developers

  [~, opt] = setUpWorkflow(opt, 'concatenate beta images and t-maps');

  if nargin < 3 || opt.dryRun
    deleteTmaps = false;
  end

  RT = 0;

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    ffxDir = getFFXdir(subLabel, opt);

    load(fullfile(ffxDir, 'SPM.mat'), 'SPM');

    model = BidsModel('file', opt.model.file);

    node = model.get_root_node();

    try
      contrasts = specifyContrasts(model, SPM, node.Name);
    catch ME
      msg = 'Could not find dummy contrasts in the BIDS stats model.';
      id = 'noDummyContrast';
      logger('ERROR', msg, 'id', id, 'filename', mfilename());
      rethrow(ME);
    end

    betaMaps = {};
    tMaps = {};

    % path to beta and t-map files.

    runs = [];
    conditions = {};

    msg = 'Concatenating the following contrasts:';
    logger('INFO', msg, 'options', opt, 'filename', mfilename());
    for iContrast = 1:length(contrasts)

      msg = sprintf('\n\t%s', contrasts(iContrast).name);
      printToScreen(msg, opt);
      betasIndices = find(contrasts(iContrast).C);

      if numel(betasIndices) > 1
        msg = sprintf(['Supposed to concatenate one beta image per contrast.' ...
                       '\nSkipping: %s'], contrasts(iContrast).name);
        id = 'concatOneImgOnly';
        logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);
        continue
      end

      % for this beta image we identify
      % - which run it came from
      % - the exact condition name stored in the SPM.mat
      % so they can be saved in a tsv for for "label" and "fold" for MVPA
      for iSess = 1:numel(SPM.Sess)
        tmp(iSess) = ismember(betasIndices, SPM.Sess(iSess).col); %#ok<*AGROW>
      end
      runs(iContrast, 1) = find(any(tmp, 1));
      clear tmp;

      parts = strsplit(SPM.xX.name{betasIndices}, ' ');
      conditions{iContrast, 1} = strjoin(parts(2:end), ' ');

      fileName = sprintf('beta_%04d.nii', betasIndices);
      fileName = validationInputFile(ffxDir, fileName);
      betaMaps{iContrast, 1} = [fileName, ',1'];

      fileName = sprintf('spmT_%04d.nii', iContrast);
      fileName = validationInputFile(ffxDir, fileName);
      tMaps{iContrast, 1} = [fileName, ',1'];

    end

    nameStructure = struct('entities', struct('sub', subLabel, ...
                                              'task', opt.taskName, ...
                                              'space', opt.space));

    % tsv
    bf = bids.File(nameStructure);
    bf.extension = '.tsv';
    bf.suffix = 'labelfold';

    tsvContent = struct('folds', runs, 'labels', {conditions});

    spm_save(fullfile(ffxDir, bf.filename), tsvContent);

    % TODO make those output filenames "BIDS derivatives" compliant
    % beta maps
    bf = bids.File(nameStructure);
    bf.extension = '.nii';
    bf.entities.desc = '4D';
    bf.suffix = 'beta';

    matlabbatch = {};
    matlabbatch = setBatch3Dto4D(matlabbatch, opt, betaMaps, RT, bf.filename);

    % t-maps
    bf.suffix = 'tmap';
    matlabbatch = setBatch3Dto4D(matlabbatch, opt, tMaps, RT, bf.filename);

    saveAndRunWorkflow(matlabbatch, 'concat_betaImg_tMaps', opt, subLabel);

    removeTmaps(tMaps, deleteTmaps, ffxDir);

    % TODO GunZip 4D image

  end

  cleanUpWorkflow(opt);

end

function removeTmaps(tMaps, deleteTmaps, ffxDir)

  if  deleteTmaps

    % delete all individual con maps
    msg = 'Deleting individual con maps ...  ';
    logger('INFO', msg, 'options', opt, 'filename', mfilename());
    for iCon = 1:length(tMaps)
      delete(fullfile(ffxDir, ['con_', sprintf('%04d', iCon), '.nii']));
    end
    logger('INFO', 'Done', 'options', opt, 'filename', mfilename());

    % delete all individual t-maps
    msg = 'Deleting individual t-maps ...  ';
    logger('INFO', msg, 'options', opt, 'filename', mfilename());
    for iTmap = 1:length(tMaps)
      delete(tMaps{iTmap}(1:end - 2));
    end
    logger('INFO', 'Done', 'options', opt, 'filename', mfilename());

  end

end
