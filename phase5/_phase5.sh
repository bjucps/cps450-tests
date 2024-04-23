if [ -z "$IS_LOCAL_TEST" ]
then
  sudo dpkg --add-architecture i386 
  sudo apt-get update >/dev/null 2>&1
  sudo apt-get install libc6:i386 libstdc++6:i386 gcc-multilib >/dev/null 2>&1
fi

require-folder $LANG_NAME
require-files $LANG_NAME/README.md $LANG_NAME/stdlib.c

cd $LANG_NAME
do-compile gradle install || exit 
do-compile --test-message "Build stdlib.c" gcc -m32 -c stdlib.c || exit

mkdir tests && cp -r $CLASS_DIR/tests/phase4/* tests

cp tests/basic/assign1.$LANG_NAME .

CMD=build/install/$LANG_NAME/bin/$LANG_NAME

[ -r assign1.s ] && rm assign1.s

run-program --test-category "Execution Tests" --test-message "compile assign1.$LANG_NAME produces assign1.s" --showoutputonpass --timeout 3 --expected assign1.s $CMD -S assign1.$LANG_NAME 

if [ -e assign1.s ]
then
  run-program --test-category "Execution Tests" --test-message "assemble assign1.s" --showoutputonpass --timeout 3 gcc -m32 assign1.s stdlib.o -oassign1
  run-program --test-category "Execution Tests" --test-message "run assign1 without crashing" --showoutputonpass --timeout 3 ./assign1
fi

[ -r assign1 ] && rm assign1

run-program --test-category "Execution Tests" --test-message "compile assign1.$LANG_NAME without -S" --showoutputonpass --timeout 3 --expected assign1 $CMD assign1.$LANG_NAME 

