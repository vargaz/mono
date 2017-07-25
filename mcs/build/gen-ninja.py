#!/usr/bin/env python

import os
import sys
import glob
import argparse
import ninja_syntax

parser = argparse.ArgumentParser (description = 'Generate ninja build files')

command = sys.argv [1]
if command == "frag":
    #
    # Generate one build target from the arguments
    #
    parser.add_argument ("--topdir", required = True, help = "Top dir where the main build.ninja file will reside")
    parser.add_argument ("--target", required = True, help = "Target file to build")
    parser.add_argument ("--csc-args", required = True, help = "Additional arguments to the csc command")
    parser.add_argument ("--sources-file", required = True, help = "The file containing the list of sources")
    parser.add_argument ("--extra-sources", required = True, help = "Additional sources")
    parser.add_argument ("--libs", required = True, help = "List of additional .dlls referenced during compilation")
    parser.add_argument ("--gen-sources-file", required = False, help = "Store list of source files into this file and use it during compilation.")
    args = parser.parse_args (sys.argv [2:])
    topdir = args.topdir
    target = args.target
    csc_args = args.csc_args
    sources_file = args.sources_file
    extra_sources = args.extra_sources
    lib_references = args.libs
    gen_sources_file = args.gen_sources_file

    dependencies = []

    sources = []
    with open (sources_file, "r") as sfile:
        for line in sfile:
            line = line.strip ()
            if "*" in line:
                for s in glob.glob (line):
                    sources.append (s)
            else:
                sources.append (line.strip ())
    for s in extra_sources.split ():
        sources.append (s)

    # Process response files
    new_csc_args = ""
    for arg in csc_args.split ():
        if arg.startswith ("@"):
            file = open (arg [1:], "r")
            for l in file.readlines ():
                new_csc_args += l.strip () + " "
            file.close ()
        else:
            new_csc_args += arg + " "
    csc_args = new_csc_args
                    
    # Make all paths relative to topdir since this will be included into
    # the ninja build file in topdir
    target = os.path.relpath (target, topdir)
    for i in range(len (sources)):
        if sources [i].strip () == "":
            continue
        sources [i] = os.path.relpath (sources [i], topdir)

    if gen_sources_file != None:
        f = open (gen_sources_file, "w")
        for src in sources:
            f.write ("{0}\n".format (src))
        f.close ()

    # Scan command line for additional file references
    new_csc_args = ""
    for arg in csc_args.split ():
        if arg.startswith ("/keyfile:") or arg.startswith ("-keyfile:"):
            file = arg [len ("/keyfile:"):]
            file = os.path.relpath (file, topdir)
            dependencies.append (file)
            new_csc_args += "/keyfile:{0} ".format (file)
        elif arg.startswith ("-resource:") or arg.startswith ("/resource:"):
            parts = arg [len ("-resource:"):].split (',')
            file = os.path.relpath (parts [0], topdir)
            dependencies.append (file)
            new_csc_args += "-resource:{0}".format (file)
            for part in parts [1:]:
                new_csc_args += ",{0}".format (part)
            new_csc_args += " "
        elif arg.startswith ("-r:") or arg.startswith ("/r:"):
            file = os.path.relpath (arg [len ("-r:"):], topdir)
            dependencies.append (file)
            new_csc_args += "-r:{0} ".format (file)
        else:
            new_csc_args += arg + " "
    csc_args = new_csc_args

    for lib in lib_references.split ():
        if '=' in lib:
            alias,lib = lib.split ('=')
            lib = os.path.relpath (lib, topdir)
            dependencies.append (lib)
            csc_args += " -r:{0}={1}".format (alias,lib)
        else:
            lib = os.path.relpath (lib, topdir)
            dependencies.append (lib)
            csc_args += " -r:{0}".format (lib)

    w = ninja_syntax.Writer (sys.stdout)

    if gen_sources_file != None:
        # Pass all sources in a response file
        # csc has a large slowdown with lots of command line arguments
        response_file = os.path.relpath (gen_sources_file, topdir)
        csc_args += " @{0}".format (response_file)
        w.build (target, "csc", inputs = [], implicit = sources + dependencies, variables = { "csc_args" : csc_args })
    else:
        w.build (target, "csc", inputs = sources, implicit = dependencies, variables = { "csc_args" : csc_args})

if command == "main":
    #
    # Create the main build.ninja file from a list of fragments
    #
    # The csc command used to build
    csc_command = sys.argv [2]

    files = sys.argv [3:]
            
    w = ninja_syntax.Writer (sys.stdout)

    # Emit the csc command line here once to make the file more readable
    w.rule ("csc", '{0} $csc_args -out:$out $in'.format (csc_command), description = "CSC $out")
    w.newline ()
    for file in files:
        with open (file, "r") as f:
            sys.stdout.write (f.read ())

        
        
