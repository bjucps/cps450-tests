
require-folder $LANG_NAME
require-files $LANG_NAME/README.md

cd $LANG_NAME
do-compile gradle install || exit 

mkdir tests && cp -r $CLASS_DIR/tests/phase4/* tests

cp tests/basic/assign1.$LANG_NAME .

CMD=build/install/$LANG_NAME/bin/$LANG_NAME

run-program --test-category "Execution Tests" --test-message "compile assign1.dream " --showoutputonpass --timeout 3 $CMD -S assign1.$LANG_NAME 
run-program --test-category "Execution Tests" --test-message "assemble assign1.s" --showoutputonpass --timeout 3 gcc -m32 assign1.s stdlib.o -oassign1
run-program --test-category "Execution Tests" --test-message "run assign1 without crashing" --showoutputonpass --timeout 3 ./assign1

[ -r assign1 ] && rm assign1

run-program --test-category "Execution Tests" --test-message "compile assign1.dream without -S" --showoutputonpass --timeout 3 $CMD assign1.$LANG_NAME 

result=FAIL
[ -r assign1 ] && result=PASS
report-result $result "Execution Tests" "compile produced assign1 executable"
