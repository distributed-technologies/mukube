# Testing 

The testsuite accompanying the build uses the [DejaGnu](gnu.org/software/dejagnu/) testing framework. The tests should be all encompassing and no fixes and new features need to be tested. Below we describe the general outline of the test folders. 

After a successful build the tests can be run from the command line. Simply change the working directory to `testsuite` and run the command `runtest`. Useful options are `-a` to show both passed and failed tests, and `--debug` which produces a detailed log file `dbg.log`, which is very useful when the tests are not behaving like expected. 

## Naming conventions

The DejaGnu framework was designed to test multiple pieces of software in multiple contexts. In DejaGnu `tool` refers to the test target, i.e. the program or component we are verifying the functionality of. Tools are tested within a context, referred to as a `board`. The `board` would traditionally describe the hardware which the `tool` is being tested on. 

## Folder Structure & File Explanation

All files related to the testing are within the [`/testsuite`](../testsuite/) folder. The layout is as follows:
```
testsuite
|   site.exp
│   
└───config
│   │   board.exp
|   |   ...
│
└───lib
│   │   tool.exp
|   |   ...
│
└───<tool>-<testgroup1>
|   │   test.exp
|   |   ...
|
└───<tool>-<testgroup2>
    |   more_test.exp
    |   ...
...
```
 - The `site.exp` file describes configurations for the program being tested. 
 - The `config/` folder contains a `board.exp` file for each `board` available. 
 - The `lib/` folder contains a `tool.exp` file for each tool to test. 

 ## Test files
 Individual tests are found inside `<name>.exp` files in the test folders as described above. They are written using [`Expect'](https://linux.die.net/man/1/expect) which is an extension of [TCL](http://www.tcl.tk/) (Tool Command Language). 

 For a quick guide to writing some basic tests, see the article [Howto: Using DejaGnu for Testing - A Simple Introduction](https://www.embecosm.com/appnotes/ean8/ean8-howto-dejagnu-1.0.html)

 Importantly, the test run one after the other in alphabetical order and there is currently no resetting of the VM with the image between tests. So if a test leaves the prompt in an undesirable state this might affect other tests. Thus it is important that the test are properly structured. 
 