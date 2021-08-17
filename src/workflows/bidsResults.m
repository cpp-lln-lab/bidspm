function bidsResults(opt)
  %
  % Computes the results for a series of contrast that can be
  % specified at the run, subject or dataset step level (see contrast specification
  % following the BIDS stats model specification).
  %
  % USAGE::
  %
  %  bidsResults([opt], funcFWHM, conFWHM)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  %
  % TODO
  %
  %     move ps file
  %     rename NIDM file
  %     if it does not exist create the default "result" field from the BIDS model file
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  currentDirectory = pwd;

  [BIDS, opt] = setUpWorkflow(opt, 'computing GLM results');

  if isempty(opt.model.file)
    opt = createDefaultModel(BIDS, opt);
  end

  % loop trough the steps and more results to compute for each contrast
  % mentioned for each step
  for iStep = 1:length(opt.result.Steps)

    % Depending on the level step we migh have to define a matlabbatch
    % for each subject or just on for the whole group
    switch opt.result.Steps(iStep).Level

      case 'run'
        warning('run level not implemented yet');

        % matlabbatch = {};
        % saveMatlabBatch(matlabbatch, 'computeFfxResults', opt, subID);

      case 'subject'

        % For each subject
        for iSub = 1:numel(opt.subjects)

          matlabbatch = {};

          subLabel = opt.subjects{iSub};

          results.dir = getFFXdir(subLabel, opt);

          for iCon = 1:length(opt.result.Steps(iStep).Contrasts)

            matlabbatch = ...
                setBatchSubjectLevelResults( ...
                                            matlabbatch, ...
                                            opt, ...
                                            subLabel, ...
                                            iStep, ...
                                            iCon);

          end

          batchName = sprintf('compute_sub-%s_results', subLabel);

          saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

          renameOutputResults(results);

          renamePng(results);

        end

      case 'dataset'

        matlabbatch = {};

        results.dir = getRFXdir(opt);
        results.contrastNb = 1;
        results.label = 'group';

        load(fullfile(results.dir, 'SPM.mat'));
        results.nbSubj = SPM.nscan;

        for iCon = 1:length(opt.result.Steps(iStep).Contrasts)

          matlabbatch = setBatchResults(matlabbatch, opt, iStep, iCon, results);

        end

        batchName = 'compute_group_level_results';

        saveAndRunWorkflow(matlabbatch, batchName, opt);

      otherwise

        error('This BIDS model does not contain an analysis step I understand.');

    end

  end

  cd(currentDirectory);

end

function renameOutputResults(results)
  % we create new name for the nifti oupput by removing the
  % spmT_XXXX prefix and using the XXXX as label- for the file

  outputFiles = spm_select('FPList', results.dir, '^spmT_[0-9].*_sub-.*$');

  for iFile = 1:size(outputFiles, 1)

    source = deblank(outputFiles(iFile, :));

    basename = spm_file(source, 'basename');
    split = strfind(basename, '_sub');
    p = bids.internal.parse_filename(basename(split + 1:end));
    p.entities.label = basename(split - 4:split - 1);
    p.use_schema = false;
    newName = bids.create_filename(p);

    target = spm_file(source, 'basename', newName);

    movefile(source, target);
  end

end

function renamePng(results)
  %
  % removes the _XXX suffix before the PNG extension.

  pngFiles = spm_select('FPList', results.dir, '^sub-.*[0-9].png$');

  for iFile = 1:size(pngFiles, 1)
    source = deblank(pngFiles(iFile, :));
    basename = spm_file(source, 'basename');
    target = spm_file(source, 'basename', basename(1:end - 4));
    movefile(source, target);
  end

end
