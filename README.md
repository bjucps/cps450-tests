# README

To run tests locally:

```
cd submission-folder
run lab1 [ -d ]
```

Add the -d option to turn on shell script debugging output.

To run tests interactively:

```
cd submission-folder
runi
# rt lab1 [ -d ]
```

# Configuring Assignments

Create _config.sh in an assignment folder to specify assignment configuration.

Options include:
* TIMEOUT - overall timeout in seconds for the test (default 30)  
  NOTE: Tests that use the gradle command to build or execute tests must configure TIMEOUT=0 (Gradle seems to be incompatible with the timeout command)
