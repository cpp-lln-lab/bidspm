---
title: "SPM: How can I use SPM image calculator (`imcalc`) to create a ROI?"
---

The image calculator utility is accessible in the SPM batch GUI:

`Batch --> SPM --> Util --> Image Calculator`

You can select the input image you want to use to create a ROI (like an atlas
for example), and then set the expression you want to use to only keep certain
voxels as part of the binary mask that will define your ROI.

If you want to keep voxels for your ROI that have a value of 51 or 52 or 53, you
would use the following expression:

```matlab
i1==51 || i1==52 || i1 == 53
```

If you save the batch and its job you will get an .m file that may contain
something like this.

```matlab
matlabbatch{1}.spm.util.imcalc.input = fullpath_to_the_image;
matlabbatch{1}.spm.util.imcalc.output = 'output';
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = 'i1==51 || i1==52 || i1 == 53';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
```
