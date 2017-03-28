#Python Script to generate a verilog wrapper which instantiates the original circuit,
#the stitchup circuit, and the checking logic on the exposed state registers 
import sys, getopt
import re
import wrapperHelper as wH

def main(argv):
    simscript = ''
    testbenchfile = ''
    cfslice=''
    original=''
    try:
        opts, args = getopt.getopt(argv, "ho:c:t:s", ["original=", "CFSlice=","tb=", "simscript="])
    except getopt.GetoptError:
            print 'Usage: python generateTB.py --original original.v --CFSlice cfslice.v --tb testbench.v --simscript vsim_script'
            sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print 'Usage: python generateTB.py --original original.v --CFSlice cfslice.v --tb testbench.v --simscript vsim_script'
            sys.exit()
        if opt in ("-o", "--original"):
            original = arg 
        if opt in ("-c", "--CFSlice"):
            cfslice = arg 
        if opt in ("-t", "--tb"):
            testbenchfile = arg 
        if opt in ("-s", "--simscript"):
            simscript = arg 

    infile = open(original, 'r')
    tboutfile = open(testbenchfile, 'w')
    workoutfile = open(simscript + '_worklib', 'w')
    simoutfile = open(simscript, 'w')

    inString = infile.read(); 

    signals = wH.getSignals(inString, 'top')
    (inputlist, outputlist) = wH.gatherIOLists(original, signals)

    testbench = "//Testbench file for the control runahead project.\n"
    testbench += "`timescale 1 ns / 1 ns\n"
    testbench += "\nmodule tbtop (\n);\n\n"
    
    testbench += "reg[0:0] clk;\n"
    testbench += "reg[0:0] reset;\n"
    testbench += "reg[0:0] start;\n"
    testbench += "wire[0:0] finish_o;\n"
    testbench += "wire[0:0] finish_c;\n"
    testbench += "reg[0:0] waitrequest;\n"
    testbench += "reg[31:0] delta;\n"
    testbench += "reg[0:0] cf_done;\n"
    testbench += "wire[31:0] return_val;\n\n\n"

    #Clock generation
    testbench += 'initial\n\tclk = 0;\nalways @(clk)\n\tclk <= #10 ~clk;\n\n'

    #instantiate the original circuit
    #testbench += "top original(\n"
    #testbench += "\t\t.clk(clk),\n"
    #testbench += "\t\t.reset(reset),\n"
    #testbench += "\t\t.start(start),\n"
    #testbench += "\t\t.finish(finish_o),\n"
    #testbench += "\t\t.waitrequest(waitrequest),\n"
    #testbench += "\t\t.return_val(return_val)\n"
    #testbench += ");\n\n\n"

    #instantiate the original circuit
    testbench += "cf_top cfslice(\n"
    testbench += "\t\t.clk(clk),\n"
    testbench += "\t\t.reset(reset),\n"
    testbench += "\t\t.start(start),\n"
    testbench += "\t\t.finish(finish_c),\n"
    testbench += "\t\t.waitrequest(waitrequest),\n"
    testbench += "\t\t.return_val(open)\n"
    testbench += ");\n\n\n"

    #Initial conditions for clock and reset signals
    #Pulses the reset condition
    testbench += 'initial begin\n@(negedge clk);\nreset <= 1;\n@(negedge clk);\nreset <= 0;\nstart <= 1;\n@(negedge clk);\nstart <= 0;\nend\n\n'

    #Initialise Delta and Result
    testbench += 'initial begin\ndelta <= 0;\ncf_done <= 0;\nend\n\n'

    #Runahead done signal 
    testbench += 'always @(finish_c) begin\n'
    testbench += '\tif(finish_c == 1) begin\n'
    testbench += '\t\tcf_done <= 1;\n'
    testbench += '\tend\n'
    testbench += 'end\n\n'
     
    #Accumulate the runahead counter 
    testbench += 'always @(negedge clk) begin\n'
    testbench += '\tif(cf_done == 1) begin\n'
    testbench += '\t\tdelta = delta + 1;\n'
    testbench += '\tend\n'
    testbench += 'end\n\n'

    #End condition
    testbench += 'always @(finish_o) begin\n'
    testbench += '\tif (finish_o == 1) begin\n'
    testbench += '\t\t$display("At t=%t clk=%b finish=%b return_val=%d runahead=%d", $time, clk, finish_o, return_val, delta);\n'
    testbench += '\t\t$display("Cycles: %d", ($time-50)/20);\n'
    testbench += '\t\t$finish;\n'
    testbench += '\tend\n'
    testbench += 'end\n\n'
#    
#    #Memory
    testbench += 'initial begin\nwaitrequest <= 1;\n@(negedge clk);\n@(negedge clk);\nwaitrequest <= 0;\nend\n\n'
#
#    #Instantiate the wrapper module
#    testbench += 'topmost dut(\n'
#    for s in signals:
#        testbench += '\t.' + s + '( '+ s + ' ),\n'
#    testbench = testbench[:-2]   
#    testbench += '\n);\n'
#
    testbench += '\n\nendmodule\n'

    tboutfile.write(testbench)
    tboutfile.close()

    #Build the file to compile the work libs
    worklibs = '#!/bin/bash\n'
    worklibs += 'rm -r -f work\n'
    worklibs += 'source ./modelsim.config\n'
    worklibs += 'vlib work\n'
    worklibs += 'vlog ${GENERIC_DIVIDER_LIBS}*.v\n'
    worklibs += 'vlog ${VERILOG_LIBS}*.v ./'+testbenchfile+' ./rhBounded_'+cfslice+'\n'
    worklibs += 'vlog ${SYSTEMVERILOG_LIBS}*.v\n'  

    workoutfile.write(worklibs)
    workoutfile.close()

    sim = '#!/bin/bash\n'
    sim += 'source ./modelsim.config\n'
    sim += 'vlog ./'+testbenchfile+' ./rhBounded_'+cfslice+'\n'
    sim += 'vsim -c tbtop -do \"run 10000000000 ; echo [simstats]; quit -f;\"\n'

    simoutfile.write(sim)
    simoutfile.close()

if __name__ == "__main__":
            main(sys.argv[1:])
