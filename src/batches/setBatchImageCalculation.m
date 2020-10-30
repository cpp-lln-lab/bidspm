% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchImageCalculation(matlabbatch, input, output, outDir, expression)

matlabbatch{end+1}.spm.util.imcalc.input = input;
matlabbatch{end}.spm.util.imcalc.output = output;
matlabbatch{end}.spm.util.imcalc.outdir = { outDir };
matlabbatch{end}.spm.util.imcalc.expression = expression;

% matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
% matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
% matlabbatch{1}.spm.util.imcalc.options.mask = 0;
% matlabbatch{1}.spm.util.imcalc.options.interp = 1;
% matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

end
