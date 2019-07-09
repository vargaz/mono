using System;
using System.IO;
using System.Collections.Generic;
using System.Reflection;
using System.Linq;

using Xunit;
using Xunit.Abstractions;
using Xunit.Sdk;

class MsgBus : IMessageBus
{
	public MsgBus(IMessageSink messageSink, bool stopOnFail = false) {
		Sink = messageSink;
	}

	IMessageSink Sink { get; set; }

	public bool QueueMessage(IMessageSinkMessage message) {
		return Sink.OnMessage (message);
	}

	public void Dispose() {
	}
}


class Discoverer : XunitTestFrameworkDiscoverer
{
	List<ITestClass> TestClasses;
	IEnumerator<ITestClass> TestClassesEnumerator;
	IMessageSink Sink;
	ITestFrameworkDiscoveryOptions DiscoveryOptions;
	IXunitTestCollectionFactory TestCollectionFactory;

	public Discoverer(IAssemblyInfo assemblyInfo,
					  ISourceInformationProvider sourceProvider,
					  IMessageSink diagnosticMessageSink,
					  ITestFrameworkDiscoveryOptions discoveryOptions,
					  IXunitTestCollectionFactory collectionFactory = null)
		: base (assemblyInfo, sourceProvider, diagnosticMessageSink, collectionFactory) {
		TestCollectionFactory = collectionFactory;
		Sink = diagnosticMessageSink;
		DiscoveryOptions = discoveryOptions;

		TestClasses = new List<ITestClass> ();
		foreach (var type in AssemblyInfo.GetTypes (false).Where (IsValidTestClass))
			TestClasses.Add (CreateTestClass (type));
		TestClassesEnumerator = TestClasses.GetEnumerator ();
	}

	protected override ITestClass CreateTestClass(ITypeInfo @class) {
		//Console.WriteLine ("CREATE: " + @class);
		return new TestClass(TestCollectionFactory.Get(@class), @class);
	}

	int nenumerated;

	public bool Step () {
		if (!TestClassesEnumerator.MoveNext ())
			return false;

		using (var messageBus = new MsgBus (Sink)) {
			var testClass = TestClassesEnumerator.Current;
			FindTestsForType (testClass, false, messageBus, DiscoveryOptions);
		}

		nenumerated ++;
		if (nenumerated % 10 == 0)
			Console.WriteLine ("" + (nenumerated * 100) / TestClasses.Count + "%");

		return true;
	}
}

class WasmRunner : IMessageSink
{
	ITestFrameworkDiscoveryOptions DiscoveryOptions;
	Discoverer discoverer;
	ITestFrameworkExecutor executor;
	ITestFrameworkExecutionOptions executionOptions;
	List<ITestCase> testCases;

	public WasmRunner (string assemblyFileName) {
		testCases = new List<ITestCase> ();

		var assembly = Assembly.LoadFrom (assemblyFileName);
		var assemblyInfo = new Xunit.Sdk.ReflectionAssemblyInfo (assembly);

		var collectionBehaviorAttribute = assemblyInfo.GetCustomAttributes(typeof(CollectionBehaviorAttribute)).SingleOrDefault();
		Console.WriteLine ("ATTR: " + collectionBehaviorAttribute);
		var testAssembly = new TestAssembly(assemblyInfo, null);

		var collectionFactory = ExtensibilityPointFactory.GetXunitTestCollectionFactory(this, collectionBehaviorAttribute, testAssembly);

		/*
		object res = null;
		res = Activator.CreateInstance (typeof (Xunit.Sdk.MemberDataDiscoverer), true, true);
		Console.WriteLine ("DISC2: " + res);
		*/

		DiscoveryOptions = TestFrameworkOptions.ForDiscovery(null);
		executionOptions = TestFrameworkOptions.ForExecution(null);

		discoverer = new Discoverer (assemblyInfo, new NullSourceInformationProvider(), this, DiscoveryOptions, collectionFactory);

		executor = new XunitTestFrameworkExecutor (assembly.GetName (), new NullSourceInformationProvider (), this);
	}

	public virtual bool OnMessage (IMessageSinkMessage msg) {
		if (msg is Xunit.Sdk.TestCaseDiscoveryMessage disc_msg) {
			testCases.Add (disc_msg.TestCase);
			return true;
		}
		//Console.WriteLine ("MSG:" + msg);		
		/*
		if (msg is Xunit.Sdk.DiagnosticMessage dmsg)
			Console.WriteLine ("MSG:" + dmsg.Message);
		else if (msg is Xunit.Sdk.TestCaseDiscoveryMessage disc_msg)
			Console.WriteLine ("TEST:" + disc_msg.TestCase.DisplayName);
		else
			Console.WriteLine ("MSG:" + msg);
		*/
		return true;
	}

	// State machine state
	int state;
	int tc_index;
	public int nrun, nfail;

	public bool Step () {
		if (state == 0) {
			Console.WriteLine ("Discovering tests...");
			state = 1;
		}
		if (state == 1) {
			int n = 0;
			while (n < 20) {
				bool res = discoverer.Step ();
				if (!res) {
					state = 2;
					return true;
				}
				n ++;
			}
			state = 2;
			return true;
		}
		if (state == 2) {
			Console.WriteLine ("Running " +  testCases.Count + " tests...");
			state = 3;
			tc_index = 0;
		}
		if (state == 3) {
			Console.WriteLine (".");
			for (int i = 0; i < 20; ++i) {
				if (tc_index == testCases.Count)
					break;
				var tc = testCases [tc_index] as XunitTestCase;
				tc_index ++;
				var method = (tc.Method as ReflectionMethodInfo).MethodInfo;

				var obj = Activator.CreateInstance (method.DeclaringType);
				Console.WriteLine (tc.DisplayName);

				if (tc is Xunit.Sdk.XunitTheoryTestCase) {
					// FIXME:
					continue;
					//var attrs = tc.TestMethod.Method.GetCustomAttributes(typeof(DataAttribute));
				}

				nrun ++;
				try {
					method.Invoke (obj, tc.TestMethodArguments);
				} catch (Exception ex) {
					Console.WriteLine ("FAIL: " + ex);
					nfail ++;
				}
			}

			//foreach (var tc in testCases)
			//	Console.WriteLine (tc.DisplayName);
            //executor.RunTests (testCases, this, executionOptions);
			if (tc_index == testCases.Count) {
				Console.WriteLine ("TESTS = "  + testCases.Count + ", RUN = " + nrun + ", FAIL = " + nfail);
				return false;
			}
		}
		return true;
	}
}

public class XunitDriver
{
	static WasmRunner testRunner;

	static void Main (String[] args) {
		Console.WriteLine ("hello");
		testRunner = new WasmRunner ("/" + args [0]);
	}

	public static string Send (string key, string val) {
		if (key == "pump") {
			try {
				bool res = testRunner.Step ();
				return res ? "IN-PROGRESS" : "DONE";
			} catch (Exception ex) {
				Console.WriteLine (ex);
				return "FAIL";
			}
		}
		if (key == "test-result") {
			if (testRunner.nfail == 0)
				return "PASS";
			else
				return "FAIL";
		}
		return "FAIL";
	}
}
