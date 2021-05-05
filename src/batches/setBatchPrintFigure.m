function matlabbatch = setBatchPrintFigure(matlabbatch, figureName)
  %
  % template to creae new setBatch functions
  %
  % USAGE::
  %
  %   matlabbatch = setBatchPrintFigure(matlabbatch, figureName)
  %
  % :param matlabbatch:
  % :type matlabbatch:
  % :param figureName:
  % :type figureName:  string
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %
  % (C) Copyright 2020 CPP_SPM developers

  if spm('CmdLine', true)

    printBatchName('print figure');

    matlabbatch{end + 1}.spm.util.print.fname = figureName;
    matlabbatch{1}.spm.util.print.fig.figname = 'Graphics';
    matlabbatch{1}.spm.util.print.opts = 'png';

  end

end
