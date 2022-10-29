function outputFilename = returnNameSkullstripOutput(inputFilename, outputType)
  %

  % (C) Copyright 2020 bidspm developers

  bf = bids.File(inputFilename, 'use_schema', false);

  bf.entities.space = 'individual';

  if strcmp(outputType, 'image')
    bf.entities.desc = 'skullstripped';
  end

  if strcmp(outputType, 'mask')
    bf.entities.desc = 'brain';
    bf.suffix = 'mask';
  end

  bf = bf.reorder_entities();

  outputFilename = bf.filename;

end
