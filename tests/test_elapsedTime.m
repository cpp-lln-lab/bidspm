function test_suite = test_elapsedTime %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_elapsedTime_basic()

    opt.globalStart = elapsedTime('globalStart');

    nbIteration = 5;
    runTime = [];

    for i=1:nbIteration
        subjectStart = elapsedTime('start');
        pause(2);
        [~, runTime] = elapsedTime('stop', subjectStart, runTime, nbIteration);
    end

    pause(1);

    cleanUpWorkflow(opt)

end
