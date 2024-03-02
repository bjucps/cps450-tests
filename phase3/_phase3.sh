
require-folder $LANG_NAME
require-files $LANG_NAME/README.md

cd $LANG_NAME
do-compile gradle install || exit 

mkdir tests && cp -r $CLASS_DIR/tests/phase3/* tests

CMD=build/install/$LANG_NAME/bin/$LANG_NAME

run-program --test-category "Execution Tests" --test-message "check decls1.dream without crashing" --showoutputonpass --timeout 3 $CMD tests/decls/decls1.$LANG_NAME
