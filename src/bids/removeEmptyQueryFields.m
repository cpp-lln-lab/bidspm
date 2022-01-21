function query = removeEmptyQueryFields(query)
  %
  % (C) Copyright 2021 CPP_SPM developers

  names = {'ses', 'run'};

  for i = 1:numel(names)
    if isfield(query, names{i}) && isempty(query.(names{i}))
      query = rmfield(query, names{i});
    end
  end

end
