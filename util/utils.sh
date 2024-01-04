#!/bin/bash

export TEST_RESULT_FILE=$BASEDIR/_testresults.log
export LOG_FILE=$BASEDIR/_log.txt
export TEST_BASE_DIR=$BASEDIR/tests
# CLASS_DIR should point to where the github class folder has been mounted
export CLASS_DIR=$BASEDIR/class
#export TEST_DIR=   # Must be set by script
#export SUBMISSION_DIR=   # Must be set by script
#export PROJECT  # set by rungh.sh
export TIMEOUT=60  # default timeout in seconds
export PASS_IMG=https://raw.githubusercontent.com/bjucps/cps450-tests/main/images/pass.png
export FAIL_IMG=https://raw.githubusercontent.com/bjucps/cps450-tests/main/images/fail.png
export LANG_NAME=dream

# Constants
CAT_MUST_PASS="Must Pass"
PASS="PASS"
FAIL="FAIL"

touch $TEST_RESULT_FILE  # Create if it doesn't exist

# Usage: report-error test-category test-name 
function report-error {
    echo "FAIL~$1~$2" >> $TEST_RESULT_FILE
}

# Usage: report-result PASS|FAIL test-category test-name 
function report-result {
    echo "$1~$2~$3" >> $TEST_RESULT_FILE
}

function must-pass-tests-failed {
    grep "^$FAIL~$CAT_MUST_PASS" $TEST_RESULT_FILE >/dev/null
}

function exit-if-must-pass-tests-failed {
    must-pass-tests-failed && exit 0
}

# Detect project name
#
# Usage: project=$(get-project-name)
#
function get-project-name {
    if [ -n "$PROJECT_NAME" ]; then
        echo $PROJECT_NAME
    else
        # Extract project name from github remote URL
        # Repo name should be of the form (ex.) cps250-project-student_github_username
        git remote get-url origin | cut -d/ -f5 | cut -d- -f2
    fi
}

# returns 0 if this test is run locally
function is-local-test {
    [ -z "$GITHUB_WORKFLOW" ]
}

# Returns 0 on success, 1 on failure
function run-tests {
    local BASH_DEBUG_OPT

    if [ -n "$DEBUG" ]; then
      BASH_DEBUG_OPT=-x
    fi

    # Read test config if it exists
    if [ -r $TEST_DIR/_config.sh ]; then
      . $TEST_DIR/_config.sh
    fi

    if [ $TIMEOUT -gt 0 ]; then
        timeout_cmd="timeout --verbose -k 1  $TIMEOUT"
        #echo "Beginning test run with overall time limit $TIMEOUT seconds..."
    fi
    
    result=0
    if ! BASH_ENV=$TEST_BASE_DIR/util/utils.sh $timeout_cmd bash $BASH_DEBUG_OPT $TEST_DIR/_$PROJECT.sh  2>&1 
    then
        if [ ${PIPESTATUS[0]} -eq 124 ]; then
          echo -e "\n\n** WARNING: Time limit of $TIMEOUT seconds exceeded. All tests aborted."
          report-error "$CAT_MUST_PASS" "Complete all tests within $TIMEOUT seconds"
        # else
        #   report-error "$CAT_MUST_PASS" "Complete basic tests successfully"
        fi
        result=1
    fi

    return $result
}

function gen-readme {

    local final_result
    
    final_result=$PASS
    if must-pass-tests-failed; then
        final_result=$FAIL
    fi

    echo $final_result >$SUBMISSION_DIR/submission.status

    if [ $final_result = "$PASS" ]; then
        icon=$PASS_IMG
    else
        icon=$FAIL_IMG
    fi

    cat > $SUBMISSION_DIR/README.md <<EOF
# Submission Status ![$final_result]($icon)

Test results generated at **$(TZ=America/New_York date)**

Category | Test | Result
---------|------|-------
$(awk -F~ -f $TEST_BASE_DIR/util/gentable.awk -v PASS_IMG="$PASS_IMG" -v FAIL_IMG="$FAIL_IMG" $TEST_RESULT_FILE | grep "^Must Pass")
$(awk -F~ -f $TEST_BASE_DIR/util/gentable.awk -v PASS_IMG="$PASS_IMG" -v FAIL_IMG="$FAIL_IMG" $TEST_RESULT_FILE | grep -v "^Must Pass")

## Detailed Test Results
\`\`\`
$(cat $LOG_FILE)
\`\`\`
EOF

}

# Usage: require-files [ --test-category <cat> ] [ --test-message <msg> ] file...
function require-files {
    local result overallresult
    local testcategory="$CAT_MUST_PASS"
    local testmessage="Required Files Submitted"

    if [ "$1" = "--test-category" ]; then
        testcategory=$2
        shift 2
    fi
    if [ "$1" = "--test-message" ]; then
        testmessage=$2
        shift 2
    fi

    overallresult=$PASS
    for file in $*
    do
        result=$PASS
        if [ ! -r "$file" ]; then
            result=$FAIL
            overallresult=$FAIL
        fi
        echo -e "\nChecking for required file $file... $result"
    done

    report-result $overallresult "$testcategory" "$testmessage"

}

function require-pdf {
    local overallresult
    local reason

    overallresult=$PASS
    for file in $*
    do
        echo -en "\nChecking for required PDF $file... "
        if [ ! -r $file ]; then
            echo "$FAIL - $file is not found"
            overallresult=$FAIL
        elif file $file | grep PDF >/dev/null; then
            echo "$PASS"
        else
            echo "$FAIL - $file is not a valid PDF"
            overallresult=$FAIL
        fi
    done

    report-result $overallresult "$CAT_MUST_PASS" "Required PDF submitted" 

}

# Compiles a program and reports success or failure
# Usage: do-compile [ --always-show-output ] [ --test-message <msg> ] [ --expect-exe <filename> ] <compile command> 
# Example:
#     do-compile --expect-exe myprog gcc -g myproc.c -omyprog
function do-compile {
    local result=$FAIL
    local detail
    local always_show=0
    local compile_cmd
    local expected_exe
    local testmessage="Successful compile"
    local opt_check=1
    
    while [ $opt_check -eq 1 ]; do

        if [ "$1" = "--always-show-output" ]; then
            always_show=1
            shift
        elif [ "$1" = "--test-message" ]; then
            testmessage=$2
            shift 2
        elif [ "$1" = "--expect-exe" ]; then
            expected_exe=$2
            shift 2
        else
            opt_check=0
        fi
    done

    echo -en "\nCompiling: $* ... "

    if detail=$($* 2>&1); then
        result=$PASS
        if [ -n "$expected_exe" -a ! -e "$expected_exe" ]; then
            result=$FAIL
            detail="No executable $expected_exe produced from compile"
        fi
    fi

    echo "$result"
    if [ $result = $FAIL -o $always_show -eq 1 ]; then
        echo "----------------------------------------------------------------"
        echo "$detail"
        echo "----------------------------------------------------------------"
    fi

    report-result $result "$CAT_MUST_PASS" "$testmessage"
 
    [ $result = $PASS ]
}

# Execute a program and report result.
#
# Usage: run-program [ --test-category <category> ] [ --test-message <message> ] [ --timeout <seconds> ] [ --maxlines <lines> ] [ --showoutputonpass ] program args...
#
# * Output of program is normally displayed only if the exit code indicates failure.
#   Use --showoutputonpass to always display output.
# * An entry is added to the test report if --test-message is specified
#
# Example: 
#    run-program --test-message "valgrind executes with no errors" --showoutputonpass valgrind ./args
#
function run-program {
    local testcategory="Warning" 
    local testmessage
    local timeout=0              # Default timeout (0 - none)
    local showoutputonpass=0 
    local maxlines=50
    local result
    local expected_fn
    local incorrect_result=0
    local opt_check=1
    local timeout_cmd

    testcategory="Warning"
    while [ $opt_check -eq 1 ]; do
        if [ "$1" = "--test-category" ]; then
            testcategory=$2
            shift 2
        elif [ "$1" = "--test-message" ]; then
            testmessage=$2
            shift 2
        elif [ "$1" = "--timeout" ]; then
            timeout=$2
            shift 2
        elif [ "$1" = "--max-lines" ]; then
            maxlines=$2
            shift 2
        elif [ "$1" = "--showoutputonpass" ]; then
            showoutputonpass=1
            shift 
        elif [ "$1" == "--expected" ]; then      
            expected_fn="$2"
            shift 2
        elif [ "$1" == "--diff-cmd" ]; then      
            diff_cmd="$2"
            shift 2
        else
            opt_check=0
        fi
    done

    let head_count=maxlines+1
    if [ $timeout -gt 0 ]; then
        timeout_cmd="timeout --verbose $timeout"
    fi

    echo -en "\nExecuting: $* ... "
    result=$FAIL
    if output=$(set -o pipefail; $timeout_cmd $* 2>&1 | head -$head_count > __output_orig.log); then
        result=OK
    fi

    line_count=$(cat __output_orig.log | wc -l)
    cat __output_orig.log | head -$maxlines > __output.log
    if [ $line_count -gt $maxlines ]
    then
        echo "... additional lines have been omitted ..." >> __output.log
    fi

    echo "$result"
    if [ $result = OK -a -n "$diff_cmd" ]; then
        if $diff_cmd &>/dev/null; then
          echo "*** Correct Result Detected***" >> __output.log
        else
          echo "*** Incorrect Result Detected***" >> __output.log
          result=$FAIL
          incorrect_result=1
        fi
    fi
    if [ -n "$expected_fn" -a -r "$expected_fn" ]; then
        # Expected file specified and exists
        if [ $incorrect_result -eq 1 -o -z "$diff_cmd" ]; then
            echo "=========================================================" >> __output.log
            echo "EXPECTED OUTPUT" >> __output.log
            echo "=========================================================" >> __output.log
            cat $expected_fn >> __output.log
        fi
    fi
    if [ $result = $FAIL -o $showoutputonpass = 1 ]; then
        echo "----------------------------------------------------------------"
        cat __output.log
        echo "----------------------------------------------------------------"
    fi

    if [ $result = OK ]; then
       result=$PASS
    fi

    if [ -n "$testmessage" ]; then
        report-result $result "$testcategory" "$testmessage"
    fi

    [ $result = $PASS ]
}



function require-folder {
    FOLDER=$1
    echo -en "\nChecking for $FOLDER folder... "
    if [ ! -d $FOLDER ]; then 
        echo $FAIL
        report-error "Must Pass" "$FOLDER directory present"
        exit 0
    fi
    echo $PASS
}
