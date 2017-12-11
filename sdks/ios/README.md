# The test runner

The test runner is an objective-c app which embeds the runtime. It has a command line interface similar to the mono runtime, i.e.
<exe> <arguments>.

# The test harness

The test harness is a C# app which automates running a test suite. It
install the app on the simulator, runs it, and collects output into
a log file.

# Make targets

Similar to the ones in xamarin-macios/tests

	* *action*-*what*-*where*-*project*

* Action

	* build-
	* install-
	* run-

* What

	* -ios-

* Where

	* -sim-

* Project

	* corlib etc.

The test apps require the corresponding test assembly to be already
built, i.e. by running make PROFILE=monotouch test in mcs/class/corlib
etc.

# Running tests on device

The app is started using ios-deploy (https://github.com/phonegap/ios-deploy):
`ios-deploy  -d -b bin/ios-dev/test-Mono.Runtime.Tests.app/ -d -a 'nunit-lite-console.exe bin/ios-dev/test-Mono.Runtime.Tests.app/monotouch_Mono.Runtime.Tests_test.dll -labels'`

Test results are transferred using Azure Event Hubs. The test app
sends events, and the test harness listens for them. The send/receive keys are
assumed to be in 'eventhub-send-key.txt' and 'eventhub-rcv-key.txt' files in
this directory. They should be created by CI etc. before the tests are ran.
The event hub is assumed to be called 'eventhub'.

This approach is chosen because establishing a direct network connection between
the host and the device is complicated since they could be on separate networks.
