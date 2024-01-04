#!/bin/bash

# Enhanced debug output
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# This script runs in my GitHub Docker container. It sets up the
# folder structure for a submission test and runs the test, then copies test results
# to the student folder

export BASEDIR=$(pwd)
. tests/util/utils.sh

if [ ! -d submission ]; then
  echo "No submission folder found"
  exit 1
fi

# Rest of script runs in submission folder
cd submission
export SUBMISSION_DIR=$(pwd)

# Don't check the initial commit
if git log --pretty=oneline -n 1 | grep -q "Initial commit"
then
  echo "Initial commit not checked."
  exit 0
fi

export PROJECT=$(get-project-name)
echo "$PROJECT submission detected"

export TEST_DIR=$TEST_BASE_DIR/$PROJECT

[ -r $TEST_DIR/_config.sh ] && . $TEST_DIR/_config.sh

# If user submitted a file named _debug, turn on DEBUG
if [ -r _debug ]
then
  export DEBUG=1
  set -x
fi

if [ -e $TEST_DIR/_$PROJECT.sh ]
then
    if [ -z "$NO_GRADLE" ]; then
      # Download gradle dependency cache
      if curl https://github.com/bjucps/cps209-tests/releases/download/tests/files.tar.gz --output files.tar.gz --silent --location --fail
      then
        tar zxf files.tar.gz --directory $BASEDIR
        export GRADLE_USER_HOME=$BASEDIR/.gradle
      else
        echo "Unable to download Gradle dependency cache. Test run will take longer than necessary."
      fi
    fi

    run-tests 2>&1 | tee $LOG_FILE
else
    if [ "$PROJECT" == "starter" ]
    then
      exit 0
    fi
    echo No tests have been defined for $PROJECT submissions... >$LOG_FILE
fi

# Generate report

echo "Publishing README.md..."

git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git config pull.rebase false  # merge (the default strategy)

git pull 

gen-readme

git add README.md submission.status
git commit -m "Automatic Tester Results"

git push


