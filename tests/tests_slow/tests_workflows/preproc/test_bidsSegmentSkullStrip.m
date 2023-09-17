% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsSegmentSkullStrip %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsSegmentSkullStrip_strip_and_seg_already_done()

  markTestAs('slow');

  opt = setOptions('vismotion');

  matlabbatch = bidsSegmentSkullStrip(opt);

  % 4 batches per subject
  assertEqual(numel(matlabbatch), 0);

end

function test_bidsSegmentSkullStrip_force_all()

  markTestAs('slow');

  opt = setOptions('vismotion');
  opt.segment.force = true;
  opt.skullstrip.force = true;

  matlabbatch = bidsSegmentSkullStrip(opt);

  % 4 batches per subject
  assertEqual(numel(matlabbatch),  4);

end

% TODO need proper dummy data for implementation

% function test_bidsSegmentSkullStrip_skip_skullstrip()
%
%   opt = setOptions('vismotion');
%   opt.segment.do = true;
%   opt.skullstrip.do = false;
%
%   matlabbatch = bidsSegmentSkullStrip(opt);
%
%   assertEqual(numel(matlabbatch),  2)
%
% end

% function test_bidsSegmentSkullStrip_skip_seg_skullstrip_already_done()
%
%   opt = setOptions('vismotion');
%   opt.segment.do = false;
%   opt.skullstrip.do = true;
%
%   matlabbatch = bidsSegmentSkullStrip(opt);
%
%   assertEqual(numel(matlabbatch),  0)
%
% end

% function test_bidsSegmentSkullStrip_skip_segment_and_skullstrip()
%
%   opt = setOptions('vismotion');
%   opt.segment.do = false;
%   opt.skullstrip.do = false;
%
%   matlabbatch = bidsSegmentSkullStrip(opt);
%
%   assertEqual(numel(matlabbatch),  0)
%
% end
