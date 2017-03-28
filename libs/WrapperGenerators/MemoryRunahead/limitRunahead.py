#Python script that is used to modify the generated legup source so that the runahead is limited
import sys, getopt
import re

def findLine(ident_string, file_buffer):
    p = re.compile(ident_string)
    for line in file_buffer:
        if p.match(line):
            return file_buffer.index(line)
    return -1


def findNext(ident_string, file_buffer, lineno):
    p = re.compile(ident_string)
    for line in file_buffer[lineno:]:
	if p.match(line):
	    for i,j in enumerate(file_buffer):
	        if j == line and i >= lineno:
	            return i
            #return file_buffer.index(line)
    return -1

def main(argv):
    original = ''
    functionName = ''
    runahead = 4
    try:
            opts, args = getopt.getopt(argv, "hi:f:r", ["input=", "functionName=", "runahead="])
    except getopt.GetoptError:
            print 'Usage: python limitRunahead.py --input original.v --functionName <name of sliced func> --runahead <Max runahead distance permitted>'
            sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print 'Usage: python limitRunahead.py --input original.v --functionName <name of sliced func> --runahead <Max runahead distance permitted>'
            sys.exit()
        if opt in ("-i", "--input"):
            original = arg 
        if opt in ("-f", "--functionName"):
            functionName = arg
        if opt in ("-r", "--runahead"):
            runahead = int(arg)

    outfilename = "rhBounded_"+original
    outfile = open(outfilename, 'w')
    origlines = open(original, 'r').readlines()

    newfile = [ ]

    #Insert Clock Gating Hardware
    searchstring = functionName + '_pSlice ' + functionName + '_pSlice_inst0 \('
    clkGateLineNo = findLine(searchstring, origlines) 
    if clkGateLineNo != -1:
        clockGatingHW = "wire [31:0] loadCount;\n"
        clockGatingHW += "wire [31:0] loadCount_pSlice;\n"
        clockGatingHW += "reg [31:0] loadCount_diff;\n"
        clockGatingHW += "reg pSlice_clk;\n"
        clockGatingHW += "reg pSlice_clk2x;\n"
        clockGatingHW += "reg pSlice_clk1x_follower;\n\n"
        clockGatingHW += "always @(*)\n"
        clockGatingHW += "begin\n"
        clockGatingHW += "\tloadCount_diff <= loadCount_pSlice - loadCount;\n"
        clockGatingHW += "\tif( loadCount_diff > "+str(runahead)+") begin\n"
        clockGatingHW += "\t\tpSlice_clk = 1'b0;\n"
        clockGatingHW += "\t\tpSlice_clk2x = 1'b0;\n"
        clockGatingHW += "\t\tpSlice_clk1x_follower = 1'b0;\n"
        clockGatingHW += "\tend\n"
        clockGatingHW += "\telse begin\n"
        clockGatingHW += "\t\tpSlice_clk = clk;\n"
        clockGatingHW += "\t\tpSlice_clk2x = clk2x;\n"
        clockGatingHW += "\t\tpSlice_clk1x_follower = clk1x_follower;\n"
        clockGatingHW += "\tend\n"
        clockGatingHW += "end\n\n\n"
        origlines.insert(clkGateLineNo, clockGatingHW)
	#Delete the clk signals to leave space for the new ones	
	del origlines[clkGateLineNo +2]
	del origlines[clkGateLineNo +2]
	del origlines[clkGateLineNo +2]
	newClks = "\t.loadCount(loadCount_pSlice),\n"
	newClks += "\t.clk(pSlice_clk),\n"
	newClks += "\t.clk2x (pSlice_clk2x),\n"
	newClks += "\t.clk1x_follower (pSlice_clk1x_follower),\n"
	origlines.insert(clkGateLineNo+2, newClks)	


    searchstring = functionName + ' ' + functionName + ' \('
    origInstantiation = findLine(searchstring, origlines)
    if origInstantiation != -1:
	loadCount = "\t.loadCount(loadCount),\n"
	origlines.insert(origInstantiation+1, loadCount)	
	
    #Add the loadCount signals to the module definitions
    searchstring = "module "+functionName
    origmod = findLine(searchstring, origlines)
    if origmod != -1:
	loadCount = "\tloadCount,\n"
	origlines.insert(origmod+2, loadCount)

    searchstring = "module "+functionName +"_pSlice"
    slicemod = findLine(searchstring, origlines)
    if slicemod != -1:
	loadCount = "\tloadCount,\n"
	origlines.insert(slicemod+2, loadCount)

    counter_process = "always @(posedge clk)\n"
    counter_process += "begin\n"
    counter_process += "\tif(reset == 1'b1 ) begin\n"
    counter_process += "\t\tloadCount = 32'd0;\n"
    counter_process += "\tend\n"
    counter_process += "\tif(memory_controller_enable_a == 1'b1 || memory_controller_enable_b == 1'b1) begin\n"
    counter_process += "\t\tloadCount = loadCount + 32'd1;\n"
    counter_process += "\tend\n"
    counter_process += "end\n\n"

    searchstring = "output reg \[31:0\] return_val;"
    o_counter = findNext(searchstring, origlines, origmod) 
    if o_counter != -1:
    	loadCountOutput = "output reg [31:0] loadCount;\n\n"
    	origlines.insert(o_counter+1, loadCountOutput)
    	origlines.insert(o_counter+2, counter_process)

    searchstring = "module "+functionName +"_pSlice"
    slicemod = findLine(searchstring, origlines)
    searchstring = "output reg \[31:0\] return_val;"
    p_counter = findNext(searchstring, origlines, slicemod) 
    if p_counter != -1:
    	loadCountOutput = "output reg [31:0] loadCount;\n\n"
    	origlines.insert(p_counter+1, loadCountOutput)
    	origlines.insert(p_counter+2, counter_process)


    outfile.writelines(origlines)
    outfile.close()

if __name__ == "__main__":
            main(sys.argv[1:])
