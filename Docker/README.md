# README

To prepare a Docker image for local testing, execute the build.cmd script in this directory.

To speed up Gradle builds on GitHub Actions, follow this procedure:

1. Navigate to https://github.com/bjucps209/submission-tests/releases
2. Delete any releases
3. Create a release with tag version *tests* and Release title *Tests*. 
   Upload c:\temp\files.tar.gz (built by build.cmd), then click Publish Release. This 
   is strictly an optional step, but should cut build times by about 15-20 seconds.
4. Execute **git tag -d tests** to delete the tests tag. This will allow you to push
   further updates to the submission-tests repository.
