docker run -it --rm -v %cd%:/submission_src -v %~dp0:/tests -e IS_LOCAL_TEST=1  -v c:\dev\cps450\class:/class  bjucps/cps450-test bash --rcfile /tests/util/bashrc -i
