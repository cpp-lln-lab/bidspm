function matlabbatch = setBatchImageCalculation(varargin)

  % Set a batch for a image calculation
  %
  % USAGE::
  %
  %   matlabbatch = setBatchImageCalculation(matlabbatch, input, output, outDir, expression)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :param input: list of images
  % :type input: cell
  %
  % :param output: name of the output file
  % :type output: char
  %
  % :param outDir: output directory
  % :type outDir: char
  %
  % :param expression: mathematical expression to apply (for example '(i1+i2)>3')
  % :type expression: char
  %
  % :param expression: data type that must be one of the following:
  %    - 'uint8'
  %    - 'int16' (default)
  %    - 'int32'
  %    - 'float32'
  %    - 'float64'
  %    - 'int8'
  %    - 'uint16'
  %    - 'uint32'
  % :type expression: char
  %
  % See ``spm_cfg_imcalc.m`` for more information::
  %
  %   ``edit(fullfile(spm('dir'), 'config', 'spm_cfg_imcalc.m'))``
  %
  %
  %
  % :returns: - :matlabbatch:
  %

  % (C) Copyright 2020 bidspm developers

  allowedDataType = {'uint8', ...
                     'int16', ...
                     'int32', ...
                     'float32', ...
                     'float64', ...
                     'int8', ...
                     'uint16', ...
                     'uint32'};

  defaultDataType = 'float32';

  args = inputParser;

  addRequired(args, 'matlabbatch', @iscell);
  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'input');
  addRequired(args, 'output', @ischar);
  addRequired(args, 'outDir', @ischar);
  addRequired(args, 'expression', @ischar);
  addOptional(args, 'dataType', defaultDataType, @ischar);

  parse(args, varargin{:});

  if ~ismember(args.Results.dataType, allowedDataType)
    list = bids.internal.create_unordered_list(allowedDataType);
    errorStruct.identifier = [mfilename() ':invalidDatatype'];
    errorStruct.message = sprintf('dataType must be one of the those types:%s', list);
    error(errorStruct);
  end

  printBatchName('image calculation', args.Results.opt);

  imcalc.input = args.Results.input;
  imcalc.output = args.Results.output;
  imcalc.outdir = { args.Results.outDir };
  imcalc.expression = args.Results.expression;
  imcalc.options.dtype = spm_type(args.Results.dataType);

  % imcalc.var = struct('name', {}, 'value', {});
  % imcalc.options.dmtx = 0;
  % imcalc.options.mask = 0;
  % imcalc.options.interp = 1;

  matlabbatch = args.Results.matlabbatch;
  matlabbatch{end + 1}.spm.util.imcalc = imcalc;

end
