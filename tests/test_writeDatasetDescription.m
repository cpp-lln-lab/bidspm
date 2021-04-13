% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_writeDatasetDescription %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_writeDatasetDescriptionBasic()

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), ...
                                'dummyData', ...
                                'derivatives', ...
                                'cpp_spm');

  copyfile( ...
           fullfile(opt.derivativesDir, 'dataset_description_old.json'), ...
           fullfile(opt.derivativesDir, 'dataset_description.json'));

  writeDatasetDescription(opt);

  content = spm_jsonread(fullfile(opt.derivativesDir, 'dataset_description.json'));

  expectedContent = returnExpectedContent();

  assertEqual(content, expectedContent);

end

function expectedContent = returnExpectedContent()

  expectedContent.Name = 'cpp_spm outputs';
  expectedContent.BIDSVersion = '1.4.1';
  expectedContent.DatasetType = 'derivative';

  expectedContent.GeneratedBy = struct( ...
                                       'Name', 'cpp_spm', ...
                                       'Version', getVersion(), ...
                                       'Container', struct('Type', '', 'Tag', ''));

  % RECOMMENDED
  expectedContent.License = '';
  expectedContent.Authors = {''};
  expectedContent.Acknowledgements = '';
  expectedContent.HowToAcknowledge = '';
  expectedContent.Funding = {''};
  expectedContent.ReferencesAndLinks = {''};
  expectedContent.DatasetDOI = '';
  expectedContent.SourceDatasets = struct( ...
                                          'DOI', 'doi:10.18112/openneuro.ds000114.v1.0.1', ...
                                          'URL', '', 'Version', '');

  expectedContent = orderfields(expectedContent);

end

% {
%     "License": "",
%     "Authors": [
%         "John Doe",
%         "Charles Darwin",
%         "Freddy Krueger"
%     ],
%     "Acknowledgements": "Thanks to all to tests that failed courageously.",
%     "HowToAcknowledge": "",
%     "Funding": [
%         "",
%         "",
%         ""
%     ],
%     "ReferencesAndLinks": [
%         "",
%         "",
%         ""
%     ],
%     "DatasetDOI": "doi:10.18112/openneuro.ds000114.v1.0.1",
%     "Name": "dummyData",
%     "BIDSVersion": "1.1.0"
% }
