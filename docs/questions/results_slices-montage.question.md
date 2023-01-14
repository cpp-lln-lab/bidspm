---
title: "Results: How can I change which slices are shown in a montage?"
---

> In `bidsspm(..., 'action', 'results', ...)`
> I get an image with the overlay of different slices.
> How can I change which slices are shown?

When you define your options the range of slices that are to be shown can be
changed like this (see `bidsResults` help section for more information):

```matlab
    % slices position in mm [a scalar or a vector]
    opt.results(1).montage.slices = -12:4:60;

    % slices orientation: can be 'axial' 'sagittal' or 'coronal'
    % axial is default
    opt.results(1).montage.orientation = 'axial';
```
