# Tests for CPP_SPM

We use a series of unit and integration tests to make sure the code behaves as
expected and to also help in development.

If you are not sure what unit and integration tests are, check the excellent
chapter about that in the
[Turing way](https://the-turing-way.netlify.app/reproducible-research/testing.html).

See
[HERE](https://github.com/cpp-lln-lab/.github/blob/main/CONTRIBUTING.md#how-to-run-the-tests)
for general information on how to run the tests.

## Folders

# Workflows

Helps to detect some very obvious bugs.

Mostly just smoke tests to do a dry run of the [workflows](../src/workflows)
with no actual assertions.

<!-- TODO add assertion by using the output of those tests to lock the output in place. -->

current lists of files with no assert:

```bash
╰─⠠⠵ grep -riL "assert" tests_*/

tests_batches/test_setBatchCoregistrationFmap.m
tests_batches/test_setBatchCreateVDMs.m
tests_unit/test_utils.m
tests_utils/test_elapsedTime.m
tests_workflows/test_bidsSegmentSkullStrip.m
tests_workflows/test_bidsLesionSegmentation.m
tests_workflows/test_bidsRename.m
tests_workflows/test_bidsSmoothing.m
tests_workflows/test_bidsRealignUnwarp.m
tests_workflows/test_bidsRealignReslice.m
```

## Add helper functions to the path

There are a some help functions you need to be added to the Matlab / Octave path to
run the tests:

```
addpath(fullfile('tests', 'utils'))
```

## Install the test data

You need to run a bash script to create some empty data files:

From within the `tests` folder.

```
make data
```

Once you have done this, run `generateLayoutMat(true)` to generate the layout of
the tests datasets.

### Run the tests

From the root folder of the bids-matlab folder, you can run the test with one
the following commands.

```matlab
% with coverage
run_tests

% without coverage
moxunit_runtests -recursive -verbose tests

% Or if you want more feedback
moxunit_runtests -verbose tests

% to run only subsets of tests indicate the folder or the file
% or run the test function file directly
moxunit_runtests -verbose tests/tests_unit

```

## Adding tests

See
[HERE](https://github.com/cpp-lln-lab/.github/blob/main/CONTRIBUTING.md#adding-more-tests)
to add more tests
