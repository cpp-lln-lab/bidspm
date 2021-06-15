function matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, output, outDir, expression)
  %
  % Set a batch for a image calculation
  %
  % USAGE::
  %
  %   matlabbatch = setBatchImageCalculation(matlabbatch, input, output, outDir, expression)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param input: list of images
  % :type input: cell
  % :param output: name of the output file
  % :type output: string
  % :param outDir: output directory
  % :type outDir: string
  % :param expression: mathematical expression to apply (for example '(i1+i2)>3')
  % :type expression: string
  %
  % :returns: - :matlabbatch:
  %
  % (C) Copyright 2020 CPP_SPM developers

  printBatchName('image calculation', opt);

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
