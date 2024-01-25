function skipIfOctave(msg)
  %
  % skip test if running on octave
  %

  % (C) Copyright 2024 bidspm developers
  if bids.internal.is_octave()
    moxunit_throw_test_skipped_exception(['Octave:', msg]);
  end

end
