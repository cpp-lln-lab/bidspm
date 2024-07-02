function matlabbatch = setBatchPrintFigure(matlabbatch, opt, figureName)
  %
  % template to create new setBatch functions
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
  % :return: matlabbatch, The matlabbatch ready to run the spm job
  % :rtype: structure
  %

  % (C) Copyright 2020 bidspm developers

  if spm('CmdLine', true)

    printBatchName('print figure', opt);

    matlabbatch{end + 1}.spm.util.print.fname = figureName;
    matlabbatch{end}.spm.util.print.fig.figname = 'Graphics';
    matlabbatch{end}.spm.util.print.opts = 'png';

  end

end
