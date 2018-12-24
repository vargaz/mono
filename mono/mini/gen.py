#
# Tablegen code generators
#

import sys
import tablegen

class MiniOpsBackend(tablegen.Backend):
    def __init__(self):
        pass

    def generate(self, table, props, output):
        if not "ARCH" in props:
            print ("Required property ARCH is not set.")
            sys.exit (1)
        arch = props ["ARCH"]
        output.write ("// GENERATED FROM '" + table.filename + "', DO NOT MODIFY.\n")
        # The defines are in the same order as in the .td file, parts of the JIT depend on this
        for m in table.defines:
            if not m.instance_of ("OpcodeGeneral"):
                continue
            if m.label == "":
                # Auto generate the label
                m.label = m.name[3:].lower()
            if m.arch != "" and not arch in m.arch:
                continue
            if m.instance_of ("Opcode3"):
                output.write ("MINI_OP3(" + m.name + ", \"" + m.label + "\", " + m.dreg.name + ", " + m.sreg1.name + ", " + m.sreg2.name + ", " + m.sreg3.name + ")\n")
            else:
                output.write ("MINI_OP(" + m.name + ", \"" + m.label + "\", " + m.dreg.name + ", " + m.sreg1.name + ", " + m.sreg2.name + ")\n")

        # Emit a table of flags
        output.write ("\n")
        output.write ("#define MINI_OPFLAG_NOSIDEFFECT (1 << 0)\n")
        output.write ("#define MINI_OPFLAG_IS_MOVE (1 << 1)\n")
        output.write ("#define MINI_OPFLAG_IS_PHI (1 << 2)\n")
        output.write ("#define MINI_OPFLAG_IS_CALL (1 << 3)\n")
        output.write ("#define MINI_OPFLAG_IS_SETCC (1 << 4)\n")
        # Max 8 flags for now
        output.write ("\n#ifdef MINI_EMIT_OPFLAGS_TABLE\n")
        output.write ("const guint8 mini_ins_flags [] = {\n")
        for m in table.defines:
            if not m.instance_of ("OpcodeGeneral"):
                continue
            if m.label == "":
                # Auto generate the label
                m.label = m.name[3:].lower()
            if m.arch != "" and not arch in m.arch:
                continue
            val = (m.noSideEffect << 0) | (m.isMove << 1) | (m.isPhi << 2) | (m.isCall << 3) | (m.isSetCC << 4)
            output.write (str (val) + ", ")
        output.write ("};\n")
        output.write ("#endif\n")

# Keep it in sync with mini.h
MONO_INST_DEST = 0
MONO_INST_SRC1 = 1
MONO_INST_SRC2 = 2
MONO_INST_SRC3 = 3
MONO_INST_LEN = 4
MONO_INST_CLOB = 5
MONO_INST_MAX = 6

class CpuDescBackend(tablegen.Backend):
    def __init__(self):
        pass

    def generate(self, table, props, output):
        # FIXME:
        arch = "AMD64"
        symbol_name = "amd64_desc"
        self.map_l_to_i = True
        
        opcodes={}
        opcode_id = 0
        # Compute opcode numbers
        for d in table.defines:
            if d.instance_of ("OpcodeGeneral"):
                if d.label == "":
                    # Auto generate the label
                    d.label = d.name[3:].lower()
                d.label = d.label.replace (".", "_")
                if not (d.arch == "" or arch in d.arch):
                    continue
                #print d.label + " " + d.arch + " " + str(opcode_id)
                # The C value of OP_...
                d.num = opcode_id
                d.used = False
                opcodes[d.label] = d
                opcode_id += 1

        # Compute all data
        for d in table.defines:
            if not d.instance_of ("InsGeneral"):
                continue
            if not d.name in opcodes:
                print "No opcode named '" + d.name + "'."
                sys.exit (1)
            opcode = opcodes [d.name]
            #print ("" + opcode.name + " " + d.len + " " + str(d.dest.spec))
            # Store all the computed data in opcode
            opcode.used = True
            opcode.spec = ["", "", "", "", "", "", "", "", "", ""]
            opcode.spec [MONO_INST_LEN] = chr (d.len)
            opcode.spec [MONO_INST_DEST] = self.compute_reg_spec (d.dest.spec, opcode.dreg.name)
            opcode.spec [MONO_INST_SRC1] = self.compute_reg_spec (d.src1.spec, opcode.sreg1.name)
            opcode.spec [MONO_INST_SRC2] = self.compute_reg_spec (d.src2.spec, opcode.sreg2.name)
            opcode.spec [MONO_INST_SRC3] = self.compute_reg_spec (d.src3.spec, opcode.sreg3.name)
            if len (d.clob.spec) > 1:
                print "Invalid clob spec '" + d.clob.spec + "'."
                sys.exit (1)
            opcode.spec [MONO_INST_CLOB] = d.clob.spec

        # Generate output
        sorted_opcodes = []
        for op in opcodes.values ():
            sorted_opcodes.append (op)
        sorted_opcodes.sort (key=lambda op: op.num)

        f = output
        f.write ("// GENERATED FROM '" + table.filename + "', DO NOT MODIFY.\n")
        f.write ("\n")

        # Write desc table
        f.write ("const char mono_{0} [] = {{\n".format (symbol_name))
        f.write ("\t\"")
        for i in range(MONO_INST_MAX):
            f.write (r"\x0")
        f.write ("\"\t/* null entry */\n")
        idx = 1
        for op in sorted_opcodes:
            if not op.used:
                continue
            try:
                f.write ("\t\"")
                for c in op.spec[:MONO_INST_MAX]:
                    if c == "":
                        f.write (r"\x0")
                        f.write ("\" \"")
                    elif c.isalnum () and ord (c) < 0x80:
                        f.write (c)
                    else:
                        f.write (r"\x{0:x}".format (ord (c)))
                        f.write ("\" \"")
                f.write ("\"\t/* {0} */\n".format (op.label))
                op.desc_idx = idx * MONO_INST_MAX
                idx += 1
            except:
                print ("Error emitting opcode '{0}': '{1}'.".format (op.name, sys.exc_info()))
                sys.exit (1)
        f.write ("};\n")

        # Write index table
        f.write ("const guint16 mono_{0}_idx [] = {{\n".format (symbol_name))
        for op in sorted_opcodes:
            if not op.used:
                f.write ("\t0,\t/* {0} */\n".format (op.label))
            else:
                f.write ("\t{0},\t/* {1} */\n".format (op.desc_idx, op.label))
        f.write ("};\n\n")

    def compute_reg_spec (self, cpu_spec, regtype):
        # regtype comes from opts.td, cpu_spec comes from cpu-<ARCH>.td
        if cpu_spec == "default":
            # Compute spec automatically
            if regtype == "NONE":
                return ""
            if regtype == "IREG":
                return "i"
            if regtype == "BREG":
                return "b"
            if regtype == "LREG":
                if self.map_l_to_i:
                    return "i"
                else:
                    return "l"
            if regtype == "VREG":
                return ""
            if regtype == "FREG":
                return "f"
            if regtype == "XREG":
                return "x"
            print "Unknown regtype '" + regtype + "'."
            sys.exit (1)
        else:
            return cpu_spec
        return ""
        
tblgen = tablegen.TableGen ()
tblgen.add_backend (MiniOpsBackend (), "--gen-mini-ops", "Generate mini-ops.h")
tblgen.add_backend (CpuDescBackend (), "--gen-cpu-desc", "Generate cpu-<ARCH>.h")
tblgen.run ()
