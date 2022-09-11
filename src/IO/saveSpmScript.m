function outputFilename = saveSpmScript(varargin)
  %
  % Saves a matlabbatch as .m file
  %
  % USAGE::
  %
  %   outputFilename = saveSpmScript(input, outputFilename)
  %
  % :param input: a ``matlabbatch`` variable (cell) or the fullpath to a ``.mat`` file
  %               containing such ``matlabbatch`` variable.
  % :param outputFilename: optional. Path to output file
  % :type outputFilename: path
  %
  % :returns: - :outputFilename: (path)
  %
  % (C) Copyright 2022 bidspm developers

  % TODO add header to output .m file

  args = inputParser;

  defaultOutputFilename = '';

  isCellOrMatFile = @(x) iscell(x) || ...
                         (exist(x, 'file') == 2 && ...
                          strcmp(spm_file(x, 'ext'), 'mat'));

  addRequired(args, 'input', isCellOrMatFile);
  addOptional(args, 'outputFilename', defaultOutputFilename, @ischar);

  parse(args, varargin{:});

  outputFilename = args.Results.outputFilename;

  if iscell(args.Results.input)
    matlabbatch = args.Results.input;

  else
    % assumes the job was saved in a matlabbatch variable
    load(args.Results.input, 'matlabbatch');

    if strcmp(outputFilename, '')
      outputFilename = spm_file(args.Results.input, 'ext', '.m');
    end

  end

  if strcmp(outputFilename, '')
    outputFilename = returnBatchFileName('', '.m');
  end

  % matlab scripts cannot have hyphens
  filename = spm_file(outputFilename, 'filename');
  outputFilename = spm_file(outputFilename, 'filename', strrep(filename, '-', '_'));

  try
    str = gencode(matlabbatch);
  catch
    % needed to use "gencode"
    spm_jobman('initcfg');
    str = gencode(matlabbatch);
  end

  [fid, msg] = fopen(outputFilename, 'w');
  if fid == -1
    cfg_message('matlabbatch:fopen', ...
                'Failed to open ''%s'' for writing:\n%s', ...
                outputFilename, ...
                msg);
  end

  fprintf(fid, '%s\n', str{:});

  fclose(fid);

end
