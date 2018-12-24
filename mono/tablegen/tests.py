from __future__ import print_function

import sys
import unittest
import tablegen

class ParseTest(unittest.TestCase):
    def testParser(self):
        src = """
class Class1 {}
def Def1 : Class1;
class Class2<string _arg1, string _arg2 = "DEFAULT"> {
        string arg1 = _arg1;
        string arg2 = _arg2;
        string arg3 = "DEFAULT2";
        Class1 arg4 = Def1;
}
def Def2 : Class2<"ARG1">;
class Class3<string arg> : Class2<arg, "ARG2"> {
        string arg5 = "DEFAULT3";
}
def Def3 : Class3<"ARG1"> {
        let arg3 = "ARG3";
};
let arg3 = "ARG3" in {
def Def4 : Class3<"ARG3">;
}
"""
        tblgen = tablegen.TableGen ()
        table = tblgen.parse (src)

        # Simple
        d = table.by_name ["Def1"]
        self.assertEqual ("Class1", d.klass.name)

        # Arguments
        d = table.by_name ["Def2"]
        # Class argument
        self.assertEqual ("ARG1", d.arg1)
        # Class argument with default
        self.assertEqual ("DEFAULT", d.arg2)
        # Field with default
        self.assertEqual ("DEFAULT2", d.arg3)
        # Field with def value
        self.assertEqual ("Def1", d.arg4.name)

        # Subclassing
        d = table.by_name ["Def3"]
        self.assertEqual ("ARG1", d.arg1)
        self.assertEqual ("ARG2", d.arg2)
        self.assertEqual ("DEFAULT3", d.arg5)

        # Let inside def
        d = table.by_name ["Def3"]
        self.assertEqual ("ARG3", d.arg3)

        # Let outside def
        d = table.by_name ["Def4"]
        self.assertEqual ("ARG3", d.arg3)

    def assertParseError(self, src):
        fail = False
        try:
            tblgen = tablegen.TableGen ()
            table = tblgen.parse (src)
            fail = True
        except:
            pass
        if fail:
            self.fail ("Should have failed on: \n\"\"\"" + src + "\"\"\"")

    def testErrorDuplicateClassName(self):
        src = """
class Class1 {}
class Class1 {}
"""
        self.assertParseError (src)

    def testErrorDuplicateDefName(self):
        src = """
class Class1 {}
def Def1 : Class1;
def Def1 : Class1;
"""
        self.assertParseError (src)

    def testErrorDuplicateDefClassName(self):
        src = """
class Class1 {}
def Class1 : Class1;
"""
        self.assertParseError (src)

    def testMissingBase(self):
        src = """
class Class1 : ClassMissing {}
"""
        self.assertParseError (src)

    def testInvalidArgCount(self):
        src = """
class Class1<string arg> {}
class Class2 : Class1 {}
"""
        self.assertParseError (src)

    def testInvalidArgCount2(self):
        src = """
class Class1<string arg> {}
class Class2 : Class1<"A", "B"> {}
"""
        self.assertParseError (src)

    def testTypeCheckingArg(self):
        src = """
class Class1<string arg> {}
class Class2 : Class1<1> {}
"""
        self.assertParseError (src)

    def testTypeCheckingMember(self):
        src = """
class Class1<string _arg> { int arg = _arg; }
def Def1: Class1<"A">;
"""
        self.assertParseError (src)

def suite():
    suite = unittest.TestSuite()
    suite.addTest(ParseTest())
    return suite

#runner = unittest.TextTestRunner()
#runner.run(suite())

if __name__ == "__main__":
    unittest.main()
