using System;
using System.IO;
using System.Reflection;
using System.Collections.Generic;
using Mono.Options;

public class AppBuilder
{
	public static void Main (String[] args) {
		new AppBuilder ().Run (args);
	}

	void check_mandatory (string val, string name) {
		if (val == null) {
			Console.Error.WriteLine ($"The {name} argument is mandatory.");
			Environment.Exit (1);
		}
	}

	void Run (String[] args) {
		string appdir = null;
		string builddir = null;
		string mono_sdkdir = null;
		string exe = null;
		var assemblies = new List<string> ();
		var p = new OptionSet () {
				{ "appdir=", s => appdir = s },
				{ "builddir=", s => builddir = s },
				{ "mono-sdkdir=", s => mono_sdkdir = s },
				{ "exe=", s => exe = s },
				{ "r=", s => assemblies.Add (s) },
			};

		var new_args = p.Parse (args).ToArray ();

		check_mandatory (appdir, "--appdir");
		check_mandatory (builddir, "--builddir");
		check_mandatory (mono_sdkdir, "--mono-sdkdir");

		Directory.CreateDirectory (builddir);

		var ninja = File.CreateText (Path.Combine (builddir, "build.ninja"));

		// Defines
		ninja.WriteLine ($"mono_sdkdir = {mono_sdkdir}");
		ninja.WriteLine ($"appdir = {appdir}");
		ninja.WriteLine ($"builddir = .");
		ninja.WriteLine ("cross = $mono_sdkdir/wasm-aot/bin/wasm32-mono-sgen");
		// Rules
		ninja.WriteLine ("rule aot");
		ninja.WriteLine ($"  command = MONO_PATH=$mono_path $cross --debug --aot=llvmonly,asmonly,no-opt,dedup-skip,static,llvm-outfile=$outfile $src_file");
		ninja.WriteLine ("  description = [AOT] $src_file -> $outfile");
		ninja.WriteLine ("rule mkdir");
		ninja.WriteLine ("  command = mkdir -p $out");
		ninja.WriteLine ("rule cpifdiff");
		ninja.WriteLine ("  command = if cmp -s $in $out ; then : ; else cp $in $out ; fi");
		ninja.WriteLine ("  restat = true");

		ninja.WriteLine ("build $appdir: mkdir");
		ninja.WriteLine ("build $appdir/managed: mkdir");

		var ofiles = "";
		var assembly_names = new List<string> ();
		foreach (var assembly in assemblies) {
			string filename = Path.GetFileName (assembly);
			var filename_noext = Path.GetFileNameWithoutExtension (filename);

			File.Copy (assembly, Path.Combine (builddir, filename), true);
			ninja.WriteLine ($"build $appdir/{filename}: cpifdiff $builddir/{filename}");

			string destdir = null;
			string srcfile = null;
			destdir = "$builddir";
			srcfile = $"{filename}";

			string outputs = $"{destdir}/{filename}.bc";
			ninja.WriteLine ($"build {outputs}: aot {srcfile}");
			ninja.WriteLine ($"  src_file={srcfile}");
			ninja.WriteLine ($"  outfile={destdir}/{filename}.bc");
			ninja.WriteLine ($"  mono_path={destdir}");

			ofiles += " " + ($"{destdir}/{filename}.bc");
		}

		ninja.Close ();
	}
}
