docker run -it --rm -v %cd%:/submission_src -v %~dp0:/tests  -v c:\dev\cps450\class:/class  bjucps/cps450-test bash --rcfile /tests/util/bashrc -i
