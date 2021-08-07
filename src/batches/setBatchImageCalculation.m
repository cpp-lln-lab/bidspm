function matlabbatch = setBatchImageCalculation(varargin)
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
  % :param expression: data type that must be one of the following:
  %    - 'uint8'
  %    - 'int16' (default)
  %    - 'int32'
  %    - 'float32'
  %    - 'float64'
  %    - 'int8'
  %    - 'uint16'
  %    - 'uint32'
  % :type expression: string
  %
  % See ``spm_cfg_imcalc.m`` for more information::
  %
  %   ``edit(fullfile(spm('dir'), 'config', 'spm_cfg_imcalc.m'))``
  %
  %
  %
  % :returns: - :matlabbatch:
  %
  % (C) Copyright 2020 CPP_SPM developers

  printBatchName('image calculation');

  [matlabbatch, input, output, outDir, expression, dataType] = deal(varargin{:});

  if isempty(dataType)
    dataType = 'int16';
  end

  allowedDataType = {'uint8', ...
                     'int16', ...
                     'int32', ...
                     'float32', ...
                     'float64', ...
                     'int8', ...
                     'uint16', ...
                     'uint32'};

  if ~ismember(dataType, allowedDataType)
    fprintf(1, '\t%s\n', string(allowedDataType));
    error('dataType must be one of the type mentionned above.');
  end

  matlabbatch{end + 1}.spm.util.imcalc.input = input;
  matlabbatch{end}.spm.util.imcalc.output = output;
  matlabbatch{end}.spm.util.imcalc.outdir = { outDir };
  matlabbatch{end}.spm.util.imcalc.expression = expression;
  matlabbatch{end}.spm.util.imcalc.options.dtype = spm_type(dataType);

  % matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
  % matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
  % matlabbatch{1}.spm.util.imcalc.options.mask = 0;
  % matlabbatch{1}.spm.util.imcalc.options.interp = 1;
  % matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

end
