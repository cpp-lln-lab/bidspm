% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchImageCalculation(matlabbatch, input, output, outDir, expression)
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
  
  printBatchName('image calculation');

  matlabbatch{end + 1}.spm.util.imcalc.input = input;
  matlabbatch{end}.spm.util.imcalc.output = output;
  matlabbatch{end}.spm.util.imcalc.outdir = { outDir };
  matlabbatch{end}.spm.util.imcalc.expression = expression;

  % matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
  % matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
  % matlabbatch{1}.spm.util.imcalc.options.mask = 0;
  % matlabbatch{1}.spm.util.imcalc.options.interp = 1;
  % matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

end
