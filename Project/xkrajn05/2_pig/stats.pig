-- Load the data in comma-separated-values format with a given schema
data_raw = 
    LOAD '$INPUT1'
    USING org.apache.pig.piggybank.storage.CSVExcelStorage
		(',', 'NO_MULTILINE', 'NOCHANGE', 'SKIP_INPUT_HEADER')
	AS (
		CURRENCY: chararray,
        TIME_PERIOD: chararray,
        OBS_VALUE: double
	);

-- Convert TIME_PERIOD into datetime format
data = FOREACH data_raw generate CURRENCY,ToDate(TIME_PERIOD, 'yyyy-MM-dd') as (TIME_PERIOD: datetime), OBS_VALUE;

-- Task 1 find max, min and avg values of each currency for the whole time period ------------------------------------------------
currencyGroup = GROUP data BY CURRENCY;

maxMinAvg = FOREACH currencyGroup GENERATE FLATTEN(group) AS (CURRENCY),
    MAX(data.OBS_VALUE) as maxValue, MIN(data.OBS_VALUE) as minValue, AVG(data.OBS_VALUE) as avgValue;


-- Task 2 part 1 find max, min, avg for CHF, GBP, USD in the last year -----------------------------------------------------------
-- Filter out and group desired currencies in last year
dataFiltered = FILTER data BY CURRENCY == 'CHF' OR CURRENCY == 'GBP' OR CURRENCY == 'USD';

lastYear =  FILTER dataFiltered BY TIME_PERIOD > SubtractDuration(ToDate('2022-12-23', 'yyyy-MM-dd'),'P1Y');
lastYearGroup = GROUP lastYear BY CURRENCY;

mma_year = FOREACH lastYearGroup GENERATE FLATTEN(group) AS (CURRENCY),
    MAX(lastYear.OBS_VALUE) as maxValue, 
    MIN(lastYear.OBS_VALUE) as minValue, 
    AVG(lastYear.OBS_VALUE) as avgValue;


-- Task 2 part 2 find max, min, avg for CHF, GBP, USD in the last moth -----------------------------------------------------------
-- Filter out and group desired currencies in last month
lastMonth = FILTER dataFiltered BY TIME_PERIOD > SubtractDuration(ToDate('2022-12-23', 'yyyy-MM-dd'),'P1M');
lastMonthGroup = GROUP lastMonth BY CURRENCY;

mma_month = FOREACH lastMonthGroup GENERATE FLATTEN(group) AS (CURRENCY),
    MAX(lastMonth.OBS_VALUE) as maxValue, 
    MIN(lastMonth.OBS_VALUE) as minValue, 
    AVG(lastMonth.OBS_VALUE) as avgValue;

-- Save result of both parts and task 1 result
resultMonthYear = UNION mma_year, mma_month;
resultMYGroupped = GROUP resultMonthYear BY 1 parallel 1;
resultMY = FOREACH resultMYGroupped GENERATE FLATTEN(resultMonthYear);

result = UNION maxMinAvg, resultMY ;

STORE result INTO '$OUTPUT'
	USING org.apache.pig.piggybank.storage.CSVExcelStorage
		(',', 'NO_MULTILINE', 'NOCHANGE', 'WRITE_OUTPUT_HEADER');
        
-- Task 3 avg values for each currency, each month during the whole period

currencyMonthGroup = GROUP data BY (GetMonth(TIME_PERIOD), CURRENCY);
maxMinAvgAllMonths = FOREACH currencyMonthGroup GENERATE FLATTEN(group) AS (MONTH, CURRENCY), AVG(data.OBS_VALUE) as avgValue;

-- Save result
STORE maxMinAvgAllMonths INTO '$OUTPUT-3'
	USING org.apache.pig.piggybank.storage.CSVExcelStorage
		(',', 'NO_MULTILINE', 'NOCHANGE', 'WRITE_OUTPUT_HEADER');

-- Task 4 currencies with larges and lowest values
maxName = ORDER maxMinAvg BY maxValue DESC;
max = LIMIT maxName 1;
minName = ORDER maxMinAvg by minValue ASC;
min = LIMIT minName 1;

-- Save result
resultUnion = UNION max, min;
resultGroupped = GROUP resultUnion BY 1 parallel 1;
result = FOREACH resultGroupped GENERATE FLATTEN(resultUnion);

STORE result INTO '$OUTPUT-4'
	USING org.apache.pig.piggybank.storage.CSVExcelStorage
		(',', 'NO_MULTILINE', 'NOCHANGE', 'WRITE_OUTPUT_HEADER');

