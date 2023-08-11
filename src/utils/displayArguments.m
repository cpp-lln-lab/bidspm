function displayArguments(varargin)
  % (C) Copyright 2023 bidspm developers
  disp('arguments passed were :');
  for i = 1:numel(varargin)
    fprintf('- ');
    disp(varargin{i});
  end
  fprintf(1, '\n');
end
