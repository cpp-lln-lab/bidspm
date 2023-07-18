function checkColumnParticipantsTsv(BIDS, columnHdr)
  %
  % Check that a given column exists in participants.tsv
  %
  % USAGE::
  %
  %   checkColumnParticipantsTsv(BIDS, columnHdr)
  %
  %

  % (C) Copyright 2023 bidspm developers

  columns = fieldnames(BIDS.raw.participants.content);
  if ~ismember(columnHdr, fieldnames(BIDS.raw.participants.content))
    msg = sprintf(['Could not find column "%s" in participants.tsv.\n', ...
                   'Available columns are: %s'], ...
                  columnHdr, ...
                  bids.internal.create_unordered_list(columns));
    logger('ERROR', msg, 'filename', mfilename, 'id', 'missingColumn');
  end
end
