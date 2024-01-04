docker build -f Docker/Dockerfile -t bjucps/cps450-test .

rem gather files needed
rem docker run -it --rm -v c:\temp:/host bjucps/cps450-test tar zcf /host/files.tar.gz -C /tmp .gradle  
