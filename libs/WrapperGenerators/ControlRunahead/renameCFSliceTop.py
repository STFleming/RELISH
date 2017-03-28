#Python Script to generate a verilog wrapper which instantiates the original circuit,
#the ControlFlow Runahead circuit. 
import sys, getopt
import re
import wrapperHelper as wH

def main(argv):
    cfSlice = ''
    try:
            opts, args = getopt.getopt(argv, "hc", ["CFSlice="])
    except getopt.GetoptError:
            print 'Usage: python renameCFSliceTop.py --CFSlice cf_slice.v'
            sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print 'Usage: python renameCFSliceTop.py --CFSlice cf_slice.v'
            sys.exit()
        if opt in ("-c", "--CFSlice"):
            cfSlice = arg 

    wH.prefixModule(cfSlice, 'cf_', 'top')
    wH.prefixModule(cfSlice, 'cf_', 'main')


if __name__ == "__main__":
            main(sys.argv[1:])
