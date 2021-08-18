% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_spm_2_bids %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_spm_2_bids_cpp_spm_mapping()

  opt = setOptions('vismotion');

  opt = set_spm_2_bids_defaults(opt);

  anatFile = 'sub-01_T1w.nii';

  pfx_in_out = {'wc1', anatFile, 'sub-01_space-IXI549Space_res-bold_label-GM_probseg.nii'; ...
                'wc2', anatFile, 'sub-01_space-IXI549Space_res-bold_label-WM_probseg.nii'; ...
                'wc3', anatFile, 'sub-01_space-IXI549Space_res-bold_label-CSF_probseg.nii' ...
               };

  for i = 1:size(pfx_in_out, 1)

    prefixes = get_prefixes(pfx_in_out, i);

    for j = 1:numel(prefixes)

      file = [prefixes{j} pfx_in_out{i, 2}];

      print_here('%s\n', file);

      filename = spm_2_bids(file, opt);

      expected = pfx_in_out{i, 3};
      assertEqual(filename, expected);

    end
  end

end

function prefixes = get_prefixes(prefix_and_output, row)
  prefixes = prefix_and_output{row, 1};
  if ~iscell(prefixes)
    prefixes = {prefixes};
  end
end

function print_here(string, file)
  test_cfg = get_test_cfg();
  if test_cfg.verbosity
    fprintf(1, string, file);
  end
end
