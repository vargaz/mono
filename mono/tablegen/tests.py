from __future__ import print_function

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

def suite():
    suite = unittest.TestSuite()
    suite.addTest(ParseTest())
    return suite

#runner = unittest.TextTestRunner()
#runner.run(suite())

if __name__ == "__main__":
    unittest.main()
