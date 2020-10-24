function test_suite = test_setBatchSubjectLevelContrasts %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setBatchSubjectLevelContrastsBasic()

    funcFWHM = 6;
    subID = '01';
    iSes = 1;
    iRun = 1;

    % directory with this script becomes the current directory
    opt.subjects = {subID};
    opt.taskName = 'auditory';
    opt.dataDir = fullfile( ...
                           fileparts(mfilename('fullpath')), ...
                           '..', 'demos',  'MoAE', 'output', 'MoAEpilot');
    opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                              '..', 'demos',  'MoAE', 'models', 'model-MoAE_smdl.json');

    opt = checkOptions(opt);

    ffxDir = fullfile(opt.derivativesDir, 'sub-01', 'stats', 'ffx_auditory', ...
                      'ffx_space-MNI_FWHM-6');

    bidsCopyRawFolder(opt, 1);

    %     matlabbatch = setBatchSubjectLevelContrasts(opt, subID, funcFWHM);

    % TODO add assert
    %     expectedBatch = returnExpectedBatch();
    %     assert(matlabbatch, returnExpectedBatch);

end

% function expectedBatch = returnExpectedBatch()
%
%
%
% end
