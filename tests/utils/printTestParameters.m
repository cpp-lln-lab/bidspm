function printTestParameters(varargin)
  %
  % prints the parameters used for a test
  %
  % USAGE::
  %
  %   printTestParameters('test_boilerplate', 0, {'individual'}, true, 0)
  %

  % (C) Copyright 2023 bidspm developers

  args = sanitize(varargin{:});

  pattern = ['\t%s: ', ...
             strjoin(repmat({'%s'}, 1, numel(args) - 1), ' / '), ...
             '\n'];
  fprintf(1, pattern, args{:});

end

function args = sanitize(varargin)
  % turn all inputs into a cellstr
  args = {};
  for i = 1:numel(varargin)
    if iscell(varargin{i})
      tmp = sanitize(varargin{i}{:});
      tmp = ['{' strjoin(tmp, ', ') '}'];
      args{end + 1} = tmp;  %#ok<*AGROW>
    else
      args{end + 1} =  stringify(varargin{i});
    end
  end
end

function out = stringify(in)
  if ischar(in)
    out = in;
    return
  end
  if isnumeric(in)
    out = num2str(in);
    return
  end
  if islogical(in)
    if in
      out = 'true';
    else
      out = 'false';
    end
    return
  end
  out = in;
end
