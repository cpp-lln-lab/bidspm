function [OS, generatedBy] = getEnvInfo(opt)
  %
  % Gets information about the environement and operating system 
  % to help generate data descriptors for the derivatives.
  %
  % USAGE::
  %
  %   [OS, generatedBy] = getEnvInfo()
  %
  % :returns: :OS: (structure) (dimension)
  %           :generatedBy: (structure) (dimension)
  %
  % (C) Copyright 2020 CPP_SPM developers

  if nargin < 1
    opt.verbosity = 2;
    opt.dryRun = false;
  end

  generatedBy(1).name = 'CPP SPM';
  generatedBy(1).Version =  getVersion();
  generatedBy(1).Description = '';
  generatedBy(1).CodeURL = returnRepoURL();
  generatedBy(1).DOI = 'https://doi.org/10.5281/zenodo.3554331';

  runsOn = 'MATLAB';
  if isOctave
    runsOn = 'Octave';
  end

  OS.name = computer();

  if ismember(OS.name, {'GLNXA64'})

    [~, result] = system('lsb_release -d');
    tokens = regexp(result, 'Description:', 'split');

    OS.name = 'unix';
    OS.version = strtrim(tokens{2});

  elseif ismember(OS.name, {'MACI64'})

    [~, result] = system('sw_vers');
    tokens = regexp(result, newline, 'split');

    ProductName = regexp(tokens{1}, 'ProductName:', 'split');
    ProductVersion = regexp(tokens{2}, 'ProductVersion:', 'split');

    OS.name = strtrim(ProductName{2});
    OS.version = strtrim(ProductVersion{2});

  elseif ismember(OS.name, 'PCWIN64')

    [~, ver] = system('ver');
    tokens = regexp(ver, 'Version ', 'split');

    OS.name = 'Microsoft Windows';
    OS.version = tokens{2}(1:end - 2);

  end

  OS.platform.name = runsOn;
  OS.platform.version = version();

  [a, b] = spm('ver');
  OS.spmVersion = [a ' - ' b];

  if opt.dryRun
    return
  end

  [keys, vals] = getenvall('system');
  for i = 1:numel(keys)

    keyname = regexprep(keys{i}, '[^a-zA-Z_]', '_');
    keyname = regexprep(keyname, '^_*', '');
    if length(keyname) > 63
      keyname = keyname(1:63);
    end

    if ismember(keyname, {'_', ''})
      continue
    end

    OS.environmentVariables.(keyname) = vals{i};

  end

end

function [keys, vals] = getenvall(method)
  % from
  % https://stackoverflow.com/questions/20004955/list-all-environment-variables-in-matlab
  if nargin < 1
    method = 'system';
  end
  method = validatestring(method, {'java', 'system'});

  switch method
    case 'java'
      map = java.lang.System.getenv();  % returns a Java map
      keys = cell(map.keySet.toArray());
      vals = cell(map.values.toArray());
    case 'system'
      if ispc()
        cmd = 'set';
      else
        cmd = 'env';
      end
      [~, out] = system(cmd);
      vars = regexp(strtrim(out), '^(.*)=(.*)$', ...
                    'tokens', 'lineanchors', 'dotexceptnewline');
      vars = vertcat(vars{:});
      keys = vars(:, 1);
      vals = vars(:, 2);
  end

  % Windows environment variables are case-insensitive
  if ispc()
    keys = upper(keys);
  end

  % sort alphabetically
  [keys, ord] = sort(keys);
  vals = vals(ord);
end
