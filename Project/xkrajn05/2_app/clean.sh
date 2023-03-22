#!/bin/sh
rm -r spark_out/maxMinAvgAll-df
rm -r spark_out/maxMin-df

if which gradle >/dev/null 2>&1; then
	GRADLE="exec gradle"
else
	GRADLE=". ./gradlew"
fi

${GRADLE} clean $@
