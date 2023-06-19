function test_suite = test_checkColumnParticipantsTsv %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_checkColumnParticipantsTsv_basic()

  BIDS.raw.participants.content = struct('foo', 1);
  checkColumnParticipantsTsv(BIDS, 'foo');

end

function test_checkColumnParticipantsTsv_fail()
  columnHdr = 'foo';
  BIDS.raw.participants.content = struct('bar', 1);
  assertExceptionThrown(@() checkColumnParticipantsTsv(BIDS, columnHdr), ...
                        'checkColumnParticipantsTsv:missingColumn');

end
