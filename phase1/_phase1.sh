
require-folder $LANG_NAME
require-files REPORT.md

cd $LANG_NAME
do-compile gradle install || exit 

mkdir tests && cp $CLASS_DIR/tests/phase1/*.$LANG_NAME tests

CMD=build/install/$LANG_NAME/bin/$LANG_NAME

echo -e "\nExecuting your tests..."
run-program --test-category "Unit Tests" --test-message "Your tests run without error" gradle test


run-program --test-category "Execution Tests" --test-message "phase1test" --timeout 3 $CMD -ds tests/phase1test.$LANG_NAME

