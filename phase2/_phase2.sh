
require-folder $LANG_NAME
require-files $LANG_NAME/README.md

cd $LANG_NAME
do-compile gradle install || exit 

mkdir tests && cp $CLASS_DIR/tests/phase2/*.$LANG_NAME tests

CMD=build/install/$LANG_NAME/bin/$LANG_NAME

run-program --test-category "Execution Tests" --test-message "parse cptestok.dream without crashing" --showoutputonpass --timeout 3 $CMD tests/cptestok.$LANG_NAME

run-program --test-category "Execution Tests" --test-message "parse cptestbad.dream without crashing" --showoutputonpass --timeout 3 $CMD tests/cptestbad.$LANG_NAME

run-program --test-category "Execution Tests" --test-message "Use -ds option" --showoutputonpass --timeout 3 $CMD -ds tests/cptestbad.$LANG_NAME
