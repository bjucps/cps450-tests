if "%1" == "" goto none
goto continue

:none
echo Usage: run asmtcode [ -d ]
goto done

:continue

setlocal
if "%2" == "-d" set DEBUG_OPT=-x
docker run -it --rm -v %cd%:/submission_src -v %~dp0:/tests -e IS_LOCAL_TEST=1 -v c:\dev\cps450\class:/class  bjucps/cps450-test bash %DEBUG_OPT% tests/rundocker.sh %*

:done