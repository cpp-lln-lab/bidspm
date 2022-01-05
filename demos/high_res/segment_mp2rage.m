% (C) Copyright 2021 CPP_SPM developers

clear;
clc;

run ../../initCppSpm.m;

%% --- parameters

subLabel = 'pilot001';

use_schema = false;

%% --- run

opt = high_res_get_option();

derivatives = bids.layout(opt.derivativesDir, use_schema);

opt.anatReference.type = 'UNIT1';
opt.query = struct('acq', 'lores',  ...
                   'prefix', '');

MP2RAGE = bids.query(derivatives, 'data', ...
                     'sub', subLabel, ...
                     'prefix', '', ...
                     'suffix', 'UNIT1', ...
                     'acq', 'lores', ...
                     'extension', '.nii');

matlabbatch = {};
matlabbatch = setBatchSegmentation(matlabbatch, opt, MP2RAGE{1});
batchName = 'segmentMp2rage';
saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

%% create GM mask
derivatives = bids.layout(opt.derivativesDir, use_schema);

gm_tpm = bids.query(derivatives, 'data', ...
                    'sub', subLabel, ...
                    'prefix', 'c1', ...
                    'suffix', 'UNIT1', ...
                    'acq', 'lores', ...
                    'extension', '.nii');

matlabbatch = {};
input = gm_tpm;
output = bids.create_filename( ...
                              struct('entities', struct('label', 'GM'), ...
                                     'suffix', 'mask', ...
                                     'prefix', '', ...
                                     'use_schema', false), ...
                              gm_tpm{1});
dataDir = spm_fileparts(gm_tpm{1});
expression = 'i1>0.95';

matlabbatch = setBatchImageCalculation(matlabbatch, input, output, dataDir, expression);
batchName = 'create_gm_binary_mask';
saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
