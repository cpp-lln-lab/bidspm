% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSubjectLevelContrasts(opt, subID, funcFWHM)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
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

  % Create Contrasts
  contrasts = specifyContrasts(ffxDir, opt.taskName, opt);

  matlabbatch = [];

  for icon = 1:size(contrasts, 2)
    matlabbatch{1}.spm.stats.con.consess{icon}.tcon.name = ...
        contrasts(icon).name;
    matlabbatch{1}.spm.stats.con.consess{icon}.tcon.convec = ...
        contrasts(icon).C;
    matlabbatch{1}.spm.stats.con.consess{icon}.tcon.sessrep = 'none';
  end

  matlabbatch{1}.spm.stats.con.spmmat = cellstr(fullfile(ffxDir, 'SPM.mat'));
  matlabbatch{1}.spm.stats.con.delete = 1;

end
