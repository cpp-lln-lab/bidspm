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
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  defaultOutputFilename = '';

  isCellOrMatFile = @(x) iscell(x) || ...
                         ( exist('file', x) == 2 && ...
                           strcmp(spm_file(x, 'ext'), '.mat') );

  addRequired(p, 'input', isCellOrMatFile);
  addOptional(p, 'outputFilename', defaultOutputFilename, @ischar);

  parse(p, varargin{:});

  if iscell(p.Results.input)
    matlabbatch = p.Results.input;
  else
    % assumes the job was saved in a matlabbatch variable
     matlabbatch = load(p.Results.input, 'matlabbatch');
  end

  outputFilename = p.Results.outputFilename;
  if strcmp(outputFilename, '')
  end

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
