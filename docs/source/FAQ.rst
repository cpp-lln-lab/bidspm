.. _faq:

Frequently asked questions
**************************

Results
=======

How can I change which slices are shown in a montage?
-----------------------------------------------------

| In the ``bidsResults.m`` I get an image with the overlay of different slices.
| How can I change which slices are shown?

When you define your options the range of slices that are to be shown can be
changed like this (see ``bidsResults`` help section for more information):

.. code-block:: matlab

    % slices position in mm [a scalar or a vector]
    opt.result.Nodes(1).Output.montage.slices = -12:4:60;

    % slices orientation: can be 'axial' 'sagittal' or 'coronal'
    % axial is default
    opt.result.Nodes(1).Output.montage.orientation = 'axial';
