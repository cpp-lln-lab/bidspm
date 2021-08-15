function matlabbatch = setBatchImageCalculation(varargin)

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

  allowedDataType = {'uint8', ...
                     'int16', ...
                     'int32', ...
                     'float32', ...
                     'float64', ...
                     'int8', ...
                     'uint16', ...
                     'uint32'};

  defaultDataType = 'float32';

  p = inputParser;

  addRequired(p, 'matlabbatch', @iscell);
  addRequired(p, 'opt', @isstruct);
  addRequired(p, 'input');
  addRequired(p, 'output', @ischar);
  addRequired(p, 'outDir', @ischar);
  addRequired(p, 'expression', @ischar);
  addOptional(p, 'dataType', defaultDataType, @ischar);

  parse(p, varargin{:});

  if ~ismember(p.Results.dataType, allowedDataType)
    list = createUnorderedList(allowedDataType);
    errorStruct.identifier = [mfilename ':invalidDatatype'];
    errorStruct.message = sprintf('dataType must be one of the those types:%s', list);
    error(errorStruct);
  end

  printBatchName('image calculation', p.Results.opt);

  imcalc.input = p.Results.input;
  imcalc.output = p.Results.output;
  imcalc.outdir = { p.Results.outDir };
  imcalc.expression = p.Results.expression;
  imcalc.options.dtype = spm_type(p.Results.dataType);

  % imcalc.var = struct('name', {}, 'value', {});
  % imcalc.options.dmtx = 0;
  % imcalc.options.mask = 0;
  % imcalc.options.interp = 1;

  matlabbatch = p.Results.matlabbatch;
  matlabbatch{end + 1}.spm.util.imcalc = imcalc;

end
