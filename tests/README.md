# Tests for CPP_SPM

We use a series of unit and integration tests to make sure the code behaves as
expected and to also help in development.

If you are not sure what unit and integration tests are, check the excellent
chapter about that in the
[Turing way](https://the-turing-way.netlify.app/reproducible-research/testing.html).

See
[HERE](https://github.com/cpp-lln-lab/.github/blob/main/CONTRIBUTING.md#how-to-run-the-tests)
for general information on how to run the tests.

## Add helper functions to the path

There are a some help functions you need to add to the Matlab / Octave path to
run the tests:

```
addpath(fullfile('tests', 'utils'))
```

## Install the test data

You need to run a bash script to create some empty data files:

From within the `tests` folder.

```
sh createDummyDataSet.sh
```

### Run the tests

From the root folder of the bids-matlab folder, you can run the test with one
the following commands.

```bash
moxunit_runtests tests

# Or if you want more feedback
moxunit_runtests tests -verbose
```

## Adding tests

See
[HERE](https://github.com/cpp-lln-lab/.github/blob/main/CONTRIBUTING.md#adding-more-tests)
to add more tests

### Style guidelines

#### Filenames

-   unit tests names: test*unit*\*

-   other tests names: test\_\*
