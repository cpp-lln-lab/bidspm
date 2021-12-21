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
        continue

        % TODO check what happens for models with a run level specified but no
        %      subject level

      case 'subject'

        for iSub = 1:numel(opt.subjects)

          subLabel = opt.subjects{iSub};

          printProcessingSubject(iSub, subLabel, opt);

          [matlabbatch, result] = bidsResultsSubject(opt, subLabel, iNode);

          batchName = sprintf('compute_sub-%s_results', subLabel);

          saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

          renameOutputResults(result);

          renamePng(result);

        end

      case 'dataset'

        [matlabbatch, result] = bidsResultsdataset(opt, iNode);

        batchName = 'compute_group_level_results';

        saveAndRunWorkflow(matlabbatch, batchName, opt);

        renameOutputResults(result);

        renamePng(result);

      otherwise

        error('This BIDS model does not contain an analysis step I understand.');

    end

  end

  cd(currentDirectory);

end

function [matlabbatch, result] = bidsResultsSubject(opt, subLabel, iNode)

  matlabbatch = {};

  result.space = opt.space;

  result.dir = getFFXdir(subLabel, opt);

  for iCon = 1:length(opt.result.Nodes(iNode).Contrasts)

    result.Contrasts = opt.result.Nodes(iNode).Contrasts(iCon);
    if isfield(opt.result.Nodes(iNode), 'Output')
      result.Output =  opt.result.Nodes(iNode).Output;
    end

    matlabbatch = setBatchSubjectLevelResults(matlabbatch, ...
                                              opt, ...
                                              subLabel, ...
                                              result);

  end

end

function [matlabbatch, result] = bidsResultsdataset(opt, iNode)

  matlabbatch = {};

  result.space = opt.space;

  for iCon = 1:length(opt.result.Nodes(iNode).Contrasts)

    result.Contrasts = opt.result.Nodes(iNode).Contrasts(iCon);
    if isfield(opt.result.Nodes(iNode), 'Output')
      result.Output =  opt.result.Nodes(iNode).Output;
    end

    result.dir = fullfile(getRFXdir(opt), result.Contrasts.Name);

    matlabbatch = setBatchGroupLevelResults(matlabbatch, ...
                                            opt, ...
                                            result);

    matlabbatch = setBatchPrintFigure(matlabbatch, ...
                                      opt, ...
                                      fullfile(result.dir, figureName(opt)));

  end

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

function filename = figureName(opt)
  p = struct( ...
             'suffix', 'designmatrix', ...
             'ext', '.png', ...
             'entities', struct( ...
                                'task', strjoin(opt.taskName, ''), ...
                                'space', opt.space));
  bidsFile = bids.File(p, false);
  filename = bidsFile.filename;
end
