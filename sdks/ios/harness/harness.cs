using System;
using System.IO;
using System.Text;
using System.Json;
using System.Threading;
using System.Diagnostics;
using Mono.Options;
using Amqp;
using Amqp.Framing;
using Amqp.Types;

abstract class ResultReader {

	public virtual void Start () {
	}

	public virtual string ReadLine () {
		return null;
	}
}


class EventHubReader : ResultReader
{
	// Parse the azure connection string into its parts
	void ParseConnStr (string connstr, out string url, out string keyname, out string key) {
		// Connection string looks like: "Endpoint=sb://<url>;SharedAccessKeyName=<user>;SharedAccessKey=<password>";
		var parts = connstr.Split (';');
		string prefix = "Endpoint=sb://";
		if (!parts [0].StartsWith (prefix))
			throw new Exception ();
		url = parts [0].Substring (prefix.Length);
		if (url.Contains ("/"))
			url = url.Substring (0, url.IndexOf ("/"));
		prefix = "SharedAccessKeyName=";
		if (!parts [1].StartsWith (prefix))
			throw new Exception ();
		keyname = parts [1].Substring (prefix.Length);
		prefix = "SharedAccessKey=";
		if (!parts [2].StartsWith (prefix))
			throw new Exception ();
		key = parts [2].Substring (prefix.Length);
	}

	string connstr;
	ReceiverLink receiver;

	public EventHubReader (string connstr) {
		this.connstr = connstr;
	}

	public override void Start () {
		string url, keyname, key;

		ParseConnStr (connstr, out url, out keyname, out key);

		Console.WriteLine ("KEY: " + url + " " + keyname + " " + key);

		var address = new Address (url, 5671, keyname, key, "/", "amqps");

		Connection connection = new Connection(address);
		Session session = new Session(connection);

		var filters = new Map ();
		filters.Add (new Symbol ("f1"), new DescribedValue (new Symbol ("apache.org:selector-filter:string"), "amqp.annotation.x-opt-offset > '@latest'"));

		var eventhubname = "eventhub";
		receiver = new ReceiverLink (session,
									 "receiver-" + eventhubname,
									 new Source () { Address = string.Format("{0}/ConsumerGroups/$default/Partitions/0", eventhubname), FilterSet = filters },
									 null);
	}

	public override string ReadLine () {
		while (true) {
			var msg = receiver.Receive ();
			if (msg == null)
				return null;
			if (msg.Body is string)
				return (msg.Body as string);
			if (msg.Body is byte[])
				return Encoding.UTF8.GetString ((byte[])msg.Body);
		}
	}
}

class LogReader : ResultReader {

	StreamReader stream;
	string app_name;

	public LogReader (StreamReader stream, string app_name) {
		this.stream = stream;
		this.app_name = app_name;
	}

	public override void Start () {
	}

	public override string ReadLine () {
		string line = stream.ReadLine ();
		if (line == null)
			return null;
		// Extract actual output
		// The lines look like:
		// 2017-11-28 14:45:16.203 Df test-corlib[5018:20c89] ***** MonoTests.System.UInt16Test.ToString_Defaults
		// except if the output contains newlines.
		if (line.Contains (app_name + "[")) {
			int pos = line.IndexOf (app_name + "[");
			pos = line.IndexOf (':', pos + 1);
			line = line.Substring (pos + 2);
		}
		return line;
	}
}

public class Harness
{
	public const string SIM_NAME = "xamarin.ios-sdk.sim";

	static void Usage () {
		Console.WriteLine ("Usage: mono harness.exe <options> <app dir>");
		Console.WriteLine ("Where options are:");
		Console.WriteLine ("\t--run-sim");
		Console.WriteLine ("\t--app=<app bundle id>");
		Console.WriteLine ("\t--logfile=<log file name>");
	}

	public static int Main (string[] args) {
		new Harness ().Run (args);
		return 0;
	}

	string bundle_id;
	string bundle_dir;
	string logfile_name;
	string eventhub_addr;
	string[] new_args;

	public void Run (string[] args) {
		string action = "";
		bundle_id = "";
		bundle_dir = "";
		logfile_name = "";

		var p = new OptionSet () {
		  { "start-sim", s => action = "start-sim" },
		  { "run-sim", s => action = "run-sim" },
		  { "run-dev", s => action = "run-dev" },
		  { "bundle-id=", s => bundle_id = s },
		  { "bundle-dir=", s => bundle_dir = s },
		  { "logfile=", s => logfile_name = s },
		  { "eventhub-addr=", s => eventhub_addr = s },
		};
		new_args = p.Parse (args).ToArray ();

		if (action == "start-sim") {
			StartSim ();
		} else if (action == "run-sim") {
			if (bundle_id == "" || bundle_dir == "") {
				Console.WriteLine ("The --bundle-id and --bundle-dir arguments are mandatory.");
				Environment.Exit (1);
			}
			RunSim ();
		} else if (action == "run-dev") {
			if (bundle_id == "" || bundle_dir == "") {
				Console.WriteLine ("The --bundle-id and --bundle-dir arguments are mandatory.");
				Environment.Exit (1);
			}
			RunDev ();
		} else {
			Usage ();
			Environment.Exit (1);
		}
	}

	void StartSim () {
		// Check whenever our simulator instance exists
		string state_line = "";
		{
			var args = "simctl list devices";
			Console.WriteLine ("Running: " + "xcrun " + args);
			var start_info = new ProcessStartInfo ("xcrun", args);
			start_info.RedirectStandardOutput = true;
			start_info.UseShellExecute = false;
			var process = Process.Start (start_info);
			var stream = process.StandardOutput;
			string line = "";
			while (true) {
				line = stream.ReadLine ();
				if (line == null)
					break;
				if (line.Contains (SIM_NAME)) {
					state_line = line;
					break;
				}
			}
			process.WaitForExit ();
			if (process.ExitCode != 0)
				Environment.Exit (1);
		}

		bool need_start = false;
		if (state_line == "") {
			// Get the runtime type
			var args = "simctl list -j runtimes";
			Console.WriteLine ("Running: " + "xcrun " + args);
			var start_info = new ProcessStartInfo ("xcrun", args);
			start_info.RedirectStandardOutput = true;
			start_info.UseShellExecute = false;
			var process = Process.Start (start_info);
			var stream = process.StandardOutput;
			JsonObject value = JsonValue.Parse (stream.ReadToEnd ()) as JsonObject;
			string runtime = value ["runtimes"][0]["identifier"];

			// Create the simulator
			args = "simctl create " + SIM_NAME + " 'iPhone 7' " + runtime;
			Console.WriteLine ("Running: " + "xcrun " + args);
			process = Process.Start ("xcrun", args);
			process.WaitForExit ();
			if (process.ExitCode != 0)
				Environment.Exit (1);
			need_start = true;
		} else if (state_line.Contains ("(Shutdown)")) {
			need_start = true;
		}

		if (need_start) {
			var args = "simctl boot " + SIM_NAME;
			Console.WriteLine ("Running: " + "xcrun " + args);
			var process = Process.Start ("xcrun", args);
			process.WaitForExit ();
			if (process.ExitCode != 0)
				Environment.Exit (1);
		}
	}

	void RunSim () {
		Console.WriteLine ("App: " + bundle_id);

		StartSim ();

		ProcessStartInfo start_info;
		string bundle_executable;

		// Install the app
		// We do this all the time since its cheap
		string exe = "xcrun";
		string args = "simctl install " + SIM_NAME + " " + bundle_dir;
		Console.WriteLine ("Running: " + exe + " " + args);
		var process = Process.Start (exe, args);
		process.WaitForExit ();
		if (process.ExitCode != 0)
			Environment.Exit (1);

		// Obtain the bundle name of the app
		exe = "plutil";
		args = "-convert json -o temp.json " + bundle_dir + "/Info.plist";
		Console.WriteLine ("Running: " + exe + " " + args);
		process = Process.Start (exe, args);
		process.WaitForExit ();
		if (process.ExitCode != 0)
			Environment.Exit (1);
		JsonObject value = JsonValue.Parse (File.ReadAllText ("temp.json")) as JsonObject;
		bundle_executable = value ["CFBundleExecutable"];

		// Terminate previous app
		exe = "xcrun";
		args = "simctl terminate " + SIM_NAME + " " + bundle_id;
		Console.WriteLine ("Running: " + exe + " " + args);
		process = Process.Start (exe, args);
		process.WaitForExit ();
		if (process.ExitCode != 0)
			Environment.Exit (1);

		// Start result reader
		Process log_process = null;
		ResultReader res_reader = null;
		if (eventhub_addr != null) {
			res_reader = new EventHubReader (eventhub_addr);
			res_reader.Start ();
		} else {
			//
			// Instead of returning test results using an extra socket connection,
			// simply read and parse the app output through the osx log facility,
			// since stdout from the app goes to logger. This allows us to
			// use the stock nunit-lite test runner.
			//

			// Start a process to read the app output through the osx log facility
			// The json output would be easier to parse, but its emitted in multi-line mode,
			// and the ending } is only emitted with the beginning of the next entry, so its
			// not possible to parse it in streaming mode.
			// We start this before the app to prevent races
			string app_name = bundle_id.Substring (bundle_id.LastIndexOf ('.') + 1);
			var logger_args = "stream --level debug --predicate 'senderImagePath contains \"" + bundle_executable + "\"' --style syslog";
			Console.WriteLine ("Running: " + "log " + logger_args);
			start_info = new ProcessStartInfo ("log", logger_args);
			start_info.RedirectStandardOutput = true;
			start_info.RedirectStandardError = true;
			start_info.UseShellExecute = false;
			log_process = Process.Start (start_info);

			TextWriter w = new StreamWriter (logfile_name);
			res_reader = new LogReader (log_process.StandardOutput, app_name);
		}

		string app_args = "";
		foreach (var a in new_args)
			app_args += a + " ";

		// Launch new app
		exe = "xcrun";
		args = "simctl launch " + SIM_NAME + " " + bundle_id + " " + app_args;
		Console.WriteLine ("Running: " + exe + " " + args);
		process = Process.Start (exe, args);
		process.WaitForExit ();
		if (process.ExitCode != 0) {
			log_process.Kill ();
			Environment.Exit (1);
		}

		//
		// Read the test results from the app output
		//
		string result_line = null;
		while (true) {
			string line = res_reader.ReadLine ();
			if (line == null)
				break;
			Console.WriteLine (line);
			if (line.Contains ("Tests run:"))
				result_line = line;
			if (line.Contains ("Exit code:"))
				break;
		}
		if (log_process != null) {
			log_process.Kill ();
			log_process.WaitForExit ();
		}
		if (result_line != null && result_line.Contains ("Errors: 0"))
			Environment.Exit (0);
		else
			Environment.Exit (1);
	}

	void RunDev () {
		Console.WriteLine ("App: " + bundle_id);

		string bundle_executable;

		// Obtain the bundle name of the app
		string exe = "plutil";
		string args = "-convert json -o temp.json " + bundle_dir + "/Info.plist";
		Console.WriteLine ("Running: " + exe + " " + args);
		var process = Process.Start (exe, args);
		process.WaitForExit ();
		if (process.ExitCode != 0)
			Environment.Exit (1);
		JsonObject value = JsonValue.Parse (File.ReadAllText ("temp.json")) as JsonObject;
		bundle_executable = value ["CFBundleExecutable"];

		// Start result reader
		Process log_process = null;
		ResultReader res_reader = null;
		if (eventhub_addr != null) {
			res_reader = new EventHubReader (eventhub_addr);
			res_reader.Start ();
		} else {
			Console.WriteLine ("--run-dev requires --eventhub-addr.");
			Environment.Exit (1);
		}

		string app_args = "";
		foreach (var a in new_args)
			app_args += a + " ";

		// Launch new app
		exe = "ios-deploy";
		args = $"-L -d -b {bundle_dir} -d -a '{app_args}'";
		Console.WriteLine ("Running: " + exe + " " + args);
		process = Process.Start (exe, args);
		process.WaitForExit ();
		if (process.ExitCode != 0) {
			log_process.Kill ();
			Environment.Exit (1);
		}

		//
		// Read the test results from the app output
		//
		string result_line = null;
		while (true) {
			string line = res_reader.ReadLine ();
			if (line == null)
				break;
			Console.WriteLine (line);
			if (line.Contains ("Tests run:"))
				result_line = line;
			if (line.Contains ("Exit code:"))
				break;
		}
		if (log_process != null) {
			log_process.Kill ();
			log_process.WaitForExit ();
		}
		if (result_line != null && result_line.Contains ("Errors: 0"))
			Environment.Exit (0);
		else if (result_line == null) {
			Console.WriteLine ("Timed out waiting for tests to finish.");
			Environment.Exit (1);
		} else {
			Environment.Exit (1);
		}
	}
}
