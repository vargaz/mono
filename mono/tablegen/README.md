# Introduction

This is a python port of LLVM's [tablegen](https://llvm.org/docs/TableGen/index.html) tool.

It has the following advantages compared to the original C++ version:

- It doesn't require compiling LLVM.
- There is no problem with host/target builds when cross compiling.
- Backends can be written in python.

# Differences from the LLVM version

Supported features:

- classes
- defs
- let
- includes

Supported data types:

- int
- string
- bit
- defs

Incompatibilities:

	class Opcode<string label> {
		string label = label;
	}
This doesn't work with llvm-tblgen, label has no value.

# Usage

	PYTHONPATH=<path> python gen.py <options> <input file>

# API

Import the module:

	import tablegen

Create a tablegen object:

	tblgen = tablegen.TableGen ()

Register code generator backends:

	tblgen.add_backend (MiniOpsBackend (), "--gen-mini-ops", "Generate mini-ops.h")

Run:

	tblgen.run ()

# Backend API

	class Backend(tablegen.Backend):
		def __init__(self):
			pass
		
		def generate(self, table, props, output):
			...

Here `table` is a `Table` object whose `defines` property returns a list of `Define` objects in the order that they appear in the input file. `props` is
a hash of name-value pairs given by the -p arguments on the command line.

`Define` has the following properties/methods:

- `name` is the name of the def.
- every field of the def is mapped to a property of the `Define` object with a python value. (i.e. a python int/string or another `Define` object).
- the `instance_of` method returns whenever the define directly or indirectly inherits from a given class, i.e.: `if define.instance_of ('Opcode'):`
