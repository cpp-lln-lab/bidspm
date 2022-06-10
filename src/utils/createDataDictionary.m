function jsonContent = createDataDictionary(tsvContent)
  %
  % USAGE::
  %
  %   jsonContent = createDataDictionary(tsvContent)
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  columns = fieldnames(tsvContent);

  for iColumns = 1:numel(columns)
    jsonContent.(columns{iColumns}) = '';
  end

end
