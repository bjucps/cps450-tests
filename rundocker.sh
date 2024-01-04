#!/bin/bash
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# This script runs in a local Docker container. It sets up the
# folder structure for a submission test and runs the test, then copies test results
# to the student folder

export BASEDIR=/.
. ../tests/util/utils.sh

if [ -z "$1" ]; then
  echo Usage: rundocker.sh asmt_code
  exit 1
fi

[ "$2" = "-d" ] && export DEBUG=1

export PROJECT=$1
export TEST_DIR=$TEST_BASE_DIR/$PROJECT

# Cleanup previous test results if we're running in the same Docker container
test -f $TEST_RESULT_FILE && rm $TEST_RESULT_FILE
test -d /submission && rm -r /submission

# Setup current test folder
cp -r /submission_src /submission
cd /submission

export SUBMISSION_DIR=$(pwd)

if [ -e $TEST_DIR/_$PROJECT.sh ]
then
    run-tests 2>&1 | tee $LOG_FILE
else
    echo "Please create $PROJECT/_$PROJECT.sh."
    exit 1 
fi

echo Test results
echo -------------------------
cat $TEST_RESULT_FILE
echo -------------------------

gen-readme

echo Overall Result: $(cat $SUBMISSION_DIR/submission.status)

#cp $LOG_FILE $TEST_RESULT_FILE README.md /submission_src
cp README.md /submission_src
