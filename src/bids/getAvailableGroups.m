function availableGroups = getAvailableGroups(opt, groupColumnHdr)

  % (C) Copyright 2024 bidspm developers
  tsvFile = fullfile(opt.dir.raw, 'participants.tsv');

  assert(exist(tsvFile, 'file') == 2);

  participants = bids.util.tsvread(tsvFile);

  columns = fieldnames(participants);
  if ~ismember(groupColumnHdr, columns)
    msg = sprintf(['Could not find column "%s" in participants.tsv.\n', ...
                   'Available columns are: %s'], ...
                  columnHdr, ...
                  bids.internal.create_unordered_list(columns));
    logger('ERROR', msg, 'filename', mfilename, 'id', 'missingColumn');
  end

  availableGroups = sort(unique(participants.(groupColumnHdr)));
end
