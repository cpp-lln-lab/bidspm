function matlabbatch = bidsResults(opt)
  %
  % Computes the results for a series of contrast that can be
  % specified at the run, subject or dataset step level (see contrast specification
  % following the BIDS stats model specification).
  %
  % USAGE::
  %
  %  bidsResults(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  % TODO
  %
  %     move ps file
  %     rename NIDM file
  %     if it does not exist create the default "result" field from the BIDS model file

  currentDirectory = pwd;

  [BIDS, opt] = setUpWorkflow(opt, 'computing GLM results');

  if isempty(opt.model.file)
    opt = createDefaultStatsModel(BIDS, opt);
  end

  % loop trough the steps and more results to compute for each contrast
  % mentioned for each step
  for iNode = 1:length(opt.result.Nodes)

    % Depending on the level step we migh have to define a matlabbatch
    % for each subject or just on for the whole group
    switch lower(opt.result.Nodes(iNode).Level)

      case 'run'
        warning('run level not implemented yet');

        % TODO check what happens for models with a run level specified but no
        %      subject level

        % matlabbatch = {};
        % saveMatlabBatch(matlabbatch, 'computeFfxResults', opt, subLabel);

      case 'subject'

        % For each subject
        for iSub = 1:numel(opt.subjects)

          matlabbatch = {};

          subLabel = opt.subjects{iSub};

          result.dir = getFFXdir(subLabel, opt);

          for iCon = 1:length(opt.result.Nodes(iNode).Contrasts)

            matlabbatch = ...
                setBatchSubjectLevelResults( ...
                                            matlabbatch, ...
                                            opt, ...
                                            subLabel, ...
                                            iNode, ...
                                            iCon);

          end

          batchName = sprintf('compute_sub-%s_results', subLabel);

          saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

          renameOutputResults(result);

          renamePng(result);

        end

      case 'dataset'

        % TODO refactor some of this with setBatchSubjectLevelResults ?

        matlabbatch = {};

        result.contrastNb = 1;
        result.label = 'group';
        result.space = opt.space;

        entities = struct('sub', '', ...
                          'task', strjoin(opt.taskName, ''), ...
                          'space', result.space, ...
                          'desc', '', ...
                          'label', sprintf('%04.0f', ...
                                           result.contrastNb), ...
                          'p', '', ...
                          'k', '', ...
                          'MC', '');

        for iCon = 1:length(opt.result.Nodes(iNode).Contrasts)

          result.Contrasts = opt.result.Nodes(iNode).Contrasts(iCon);

          result.dir = fullfile(getRFXdir(opt), result.Contrasts.Name);

          load(fullfile(result.dir, 'SPM.mat'));
          result.nbSubj = SPM.nscan;

          result.outputNameStructure = struct( ...
                                              'suffix', 'spmT', ...
                                              'ext', '.nii', ...
                                              'use_schema', 'false', ...
                                              'entities', entities);

          matlabbatch = setBatchResults(matlabbatch, result);

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
  % we create new name for the nifti output by removing the
  % spmT_XXXX prefix and using the XXXX as label- for the file

  outputFiles = spm_select('FPList', results.dir, '^spmT_[0-9].*_sub-.*$');

  for iFile = 1:size(outputFiles, 1)

    source = deblank(outputFiles(iFile, :));

    basename = spm_file(source, 'basename');
    split = strfind(basename, '_sub');
    p = bids.internal.parse_filename(basename(split + 1:end));
    p.entities.label = basename(split - 4:split - 1);

    bidsFile = bids.File(p);

    target = spm_file(source, 'basename', bidsFile.filename);

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
