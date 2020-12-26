% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subID, funcFWHM)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subID, funcFWHM)
  %
  % :param argin1: Options chosen for the analysis. See ``checkOptions()``.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %

  printBatchName('subject level contrasts specification');

  ffxDir = getFFXdir(subID, funcFWHM, opt);

  matlabbatch{end + 1}.spm.stats.con.spmmat = cellstr(fullfile(ffxDir, 'SPM.mat'));
  matlabbatch{end}.spm.stats.con.delete = 1;

  % Create Contrasts
  contrasts = specifyContrasts(ffxDir, opt.taskName, opt);

  for icon = 1:size(contrasts, 2)
    matlabbatch{end}.spm.stats.con.consess{icon}.tcon.name = ...
        contrasts(icon).name;
    matlabbatch{end}.spm.stats.con.consess{icon}.tcon.convec = ...
        contrasts(icon).C;
    matlabbatch{end}.spm.stats.con.consess{icon}.tcon.sessrep = 'none';
  end

end
