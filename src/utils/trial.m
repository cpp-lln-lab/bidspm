%trial


globalStart = elapsedTime('globalStart');


elapsedTime('start');


WaitSecs(1);


elapsedTime('stop');

WaitSecs(1);

elapsedTime('globalStop', globalStart);
