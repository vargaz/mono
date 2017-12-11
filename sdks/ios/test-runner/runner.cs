using System;
using System.IO;
using System.Linq;
using System.Text;
using NUnitLite.Runner;
using NUnit.Framework.Internal;
using Amqp;
using Amqp.Framing;
using Amqp.Types;

class EventHubWriter : TextWriter
{
	SenderLink sender;

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

	public EventHubWriter () {
		string connstr = File.ReadAllLines ("eventhub-send-key.txt") [0];
		string url, user, password;

		ParseConnStr (connstr, out url, out user, out password);
		var eventhubname = "eventhub";

		Address address = new Address (url, 5671, user, password, "/", "amqps");
		Connection connection = new Connection(address);
		Session session = new Session(connection);

		sender = new SenderLink (session,
								 "send-link:" + eventhubname,
								 $"{eventhubname}/Partitions/0");
	}

	public override void Write(char value) {
		System.Console.WriteLine (value);
	}

	public override void Write(string value) {
		System.Console.Write (value);
	}

	public override void WriteLine(string value) {
		System.Console.WriteLine (value);

		var msg = new Message (value);
		msg.ApplicationProperties = new ApplicationProperties ();
		msg.ApplicationProperties ["sender"] = "x";
		sender.Send (msg, null, null);
	}

	public override System.Text.Encoding Encoding {
		get { return System.Text.Encoding.Default; }
    }
}

public class TestRunner
{
	public static int Main(string[] args) {
		TextUI runner;

		if (File.Exists ("eventhub-send-key.txt")) {
			var writer = new EventHubWriter ();

			runner = new TextUI (writer);
			runner.Execute (args);

			writer.WriteLine ("Exit code: " + (runner.Failure ? 1 : 0));
		} else {
			runner = new TextUI ();
			runner.Execute (args);
		}
            
		return (runner.Failure ? 1 : 0);
    }
}
