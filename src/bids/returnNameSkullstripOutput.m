function outputFilename = returnNameSkullstripOutput(inputFilename, outputType)
  %
  % (C) Copyright 2020 CPP_SPM developers

  bf = bids.File(inputFilename, 'use_schema', false);
  bf.entity_order();

  bf.entities.space = 'individual';

  if strcmp(outputType, 'image')
    bf.entities.desc = 'skullstripped';
  end

  if strcmp(outputType, 'mask')
    bf.entities.label = 'brain';
    bf.suffix = 'mask';

    if isfield(bf.entities, 'desc')
      bf.entities.desc = '';
    end

  end

  bf = bf.reorder_entities();

  outputFilename = bf.filename;

end
