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
    outfilename = '' 
    try:
            opts, args = getopt.getopt(argv, "hi:o:f", ["input=","output=", "functionName="])
    except getopt.GetoptError:
            print 'Usage: python insertAXIsignals.py --input original.v --output modified.v --functionName <name of sliced func>'
            sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print 'Usage: python insertAXIsignals.py --input original.v --output modified.v --functionName <name of sliced func>'
            sys.exit()
        if opt in ("-i", "--input"):
            original = arg 
        if opt in ("-o", "--output"):
            outfilename = arg 
        if opt in ("-f", "--functionName"):
            functionName = arg

    outfile = open(outfilename, 'w')
    origlines = open(original, 'r').readlines()

    newfile = [ ]

    searchstring = "module " + functionName + "_top"
    origModuleLineNo = findLine(searchstring, origlines)
    if origModuleLineNo != -1:
	origTopExtraSignals = "\t\tru_res,\n\t\tru_finish,\n"
	origlines.insert(origModuleLineNo+2, origTopExtraSignals)
    else:
	print "Error: could not find original toplevel module!\n"
	exit(0)

    searchstring = "module " +functionName+ "+_pSlice_top"
    sliceModuleLineNo = findLine(searchstring, origlines)
    if sliceModuleLineNo != -1:
	sliceTopExtraSignals = "\t\tru_finish,\n"
	origlines.insert(sliceModuleLineNo+2, sliceTopExtraSignals)
    else:
	print "Error: could not find the slice toplevel module!\n"
	exit(0)

    o = origModuleLineNo
    s = sliceModuleLineNo
    if origModuleLineNo < sliceModuleLineNo:
	origFirst = True
    else:
	origFirst = False

    #-------------- Modifying the original circuit Verilog----------------------

    #------ I/O declarations 
    searchstring = "input csi_clockreset_clk;\n" 
    if origFirst:
        endOfOrigModDecl = findLine(searchstring, origlines[:s])
	if endOfOrigModDecl == -1:
	    print "Error: could not find the IO declaration section.\n"
	    exit(0)
    else:
        endOfOrigModDecl = findLine(searchstring, origlines[o:])
	if endOfOrigModDecl == -1:
	    print "Error: could not find the IO declaration section.\n"
	    exit(0)
	endOfOrigModDecl = endOfOrigModDecl + o
	
    origTopIODecl = "output ru_finish;\noutput reg [31:0] ru_res;\n"
    origlines.insert(endOfOrigModDecl, origTopIODecl)

    #------ SDRAM flag A 
    searchstring = "assign flag_to_sdram_a = memory_address_a\[30\];" 
    if origFirst:
        sdram_a_flag_orig = findLine(searchstring, origlines[:s])
	if sdram_a_flag_orig == -1:
	    print "Error: could not find the sdram_a_flag in the original.\n"
	    exit(0)
    else:
        sdram_a_flag_orig = findLine(searchstring, origlines[o:])
	if sdram_a_flag_orig == -1:
	    print "Error: could not find the sdram_a_flag in the original.\n"
	    exit(0)
	sdram_a_flag_orig = sdram_a_flag_orig + o

    del origlines[sdram_a_flag_orig]	
    origNewSDRAMaFlag = "assign flag_to_sdram_a = memory_address_a[30] || memory_address_a[29];\n"
    origlines.insert(sdram_a_flag_orig, origNewSDRAMaFlag)

    #------ SDRAM flag B 
    searchstring = "assign flag_to_sdram_b = memory_address_b\[30\];" 
    if origFirst:
        sdram_b_flag_orig = findLine(searchstring, origlines[:s])
        if sdram_b_flag_orig == -1:
            print "Error: could not find the sdram_b_flag in the original.\n"
            exit(0)
    else:
        sdram_b_flag_orig = findLine(searchstring, origlines[o:])
        if sdram_b_flag_orig == -1:
            print "Error: could not find the sdram_b_flag in the original.\n"
            exit(0)
        sdram_b_flag_orig = sdram_b_flag_orig + o

    del origlines[sdram_b_flag_orig]	
    origNewSDRAMbFlag = "assign flag_to_sdram_b = memory_address_b[30] || memory_address_b[29];\n"
    origlines.insert(sdram_b_flag_orig, origNewSDRAMbFlag)
    #------ Assign ru_res and ru_finish 
    ru_finish_orig_assign = "assign ru_finish = finish_reg;\n"
    ru_finish_orig_assign += "\n\nalways @(posedge clk) begin\n"
    ru_finish_orig_assign += "\tif(reset) begin\n"
    ru_finish_orig_assign += "\t\tru_res <= 32'd0;\n"
    ru_finish_orig_assign += "\tend\n"
    ru_finish_orig_assign += "\telse if(finish_reg) begin\n"
    ru_finish_orig_assign += "\t\tru_res <= return_val;\n"
    ru_finish_orig_assign += "\tend\n"
    ru_finish_orig_assign += "end\n\n\n"
    origlines.insert(sdram_b_flag_orig+3, ru_finish_orig_assign);

    #------ start_reg assignment 
    searchstring = "\t+start_reg <= start;\n" 
    if origFirst:
        start_reg_orig_lineno = findLine(searchstring, origlines[:s])
	if start_reg_orig_lineno == -1:
	    print "Error: could not find the start_reg assignment in the original.\n"
	    exit(0)
    else:
        start_reg_orig_lineno = findLine(searchstring, origlines[o:])
	if start_reg_orig_lineno == -1:
	    print "Error: could not find the start_reg assignment in the original.\n"
	    exit(0)
	start_reg_orig_lineno = start_reg_orig_lineno + o
    del origlines[start_reg_orig_lineno]	
    newStartRegAssignment = "\tif(reset)\n\t\tstart_reg<=1'b0;\n\tif(start)\n\t\tstart_reg<=1'b1;\n\tif(finish)\n\t\tstart_reg<=1'b0;\n"
    origlines.insert(start_reg_orig_lineno, newStartRegAssignment)
 
    #------- module start signal replacement 
    searchstring= "\t+\.start\(start\),\n"
    if origFirst:
        instantiated_start_lineno = findLine(searchstring, origlines[:s])
        if instantiated_start_lineno == -1:
            print "Error: could not locate the instantiated start signal.\n"
            exit(0)
    else:
        instantiated_start_lineno = findLine(searchstring, origlines[o:])
        if instantiated_start_lineno == -1:
            print "Error: could not locate the instantiated start signal.\n"
            exit(0)
        instantiated_start_lineno = instantiated_start_lineno + o 
    del origlines[instantiated_start_lineno]
    new_start_instantiation = "\t\t.start(start_reg),\n"
    origlines.insert(instantiated_start_lineno, new_start_instantiation)

    #----------------------------------------------------------------------------


    #-------------- Modifying the pSlice circuit Verilog----------------------

    #------ I/O declarations 
    searchstring = "input csi_clockreset_clk;\n" 
    if origFirst:
        endOfSliceModDecl = findLine(searchstring, origlines[s:])
	if endOfSliceModDecl == -1:
	    print "Error: could not find the IO declaration section for slice.\n"
	    exit(0)
	endOfSliceModDecl = endOfSliceModDecl + s
    else:
        endOfSliceModDecl = findLine(searchstring, origlines[:o])
	if endOfSliceModDecl == -1:
	    print "Error: could not find the IO declaration section for slice.\n"
	    exit(0)
	
    sliceTopIODecl = "output ru_finish;\n"
    origlines.insert(endOfSliceModDecl, sliceTopIODecl)

    #------ SDRAM flag A 
    searchstring = "assign flag_to_sdram_a = memory_address_a\[30\];" 
    if origFirst:
        sdram_a_flag_slice = findLine(searchstring, origlines[s:])
	if sdram_a_flag_slice == -1:
	    print "Error: could not find the sdram_a_flag in the sliceinal.\n"
	    exit(0)
	sdram_a_flag_slice = sdram_a_flag_slice + s
    else:
        sdram_a_flag_slice = findLine(searchstring, origlines[:o])
	if sdram_a_flag_slice == -1:
	    print "Error: could not find the sdram_a_flag in the sliceinal.\n"
	    exit(0)

    del origlines[sdram_a_flag_slice]	
    sliceNewSDRAMaFlag = "assign flag_to_sdram_a = memory_address_a[30] || memory_address_a[29];\n"
    origlines.insert(sdram_a_flag_slice, sliceNewSDRAMaFlag)

    #------ SDRAM flag B 
    searchstring = "assign flag_to_sdram_b = memory_address_b\[30\];" 
    if origFirst:
        sdram_b_flag_slice = findLine(searchstring, origlines[s:])
	if sdram_b_flag_slice == -1:
	    print "Error: could not find the sdram_b_flag in the sliceinal.\n"
	    exit(0)
	sdram_b_flag_slice = sdram_b_flag_slice + s 
    else:
        sdram_b_flag_slice = findLine(searchstring, origlines[:o])
	if sdram_b_flag_slice == -1:
	    print "Error: could not find the sdram_b_flag in the sliceinal.\n"
	    exit(0)

    del origlines[sdram_b_flag_slice]	
    sliceNewSDRAMbFlag = "assign flag_to_sdram_b = memory_address_b[30] || memory_address_b[29];\n"
    origlines.insert(sdram_b_flag_slice, sliceNewSDRAMbFlag)

    #------ ru_finish assignment
    ru_finish_slice_assign = "assign ru_finish = finish_reg;\n"
    origlines.insert(sdram_b_flag_slice+3,ru_finish_slice_assign);

    #----------------------------------------------------------------------------
	#renaming the module names
		# Original circuit
    searchstring = "module " +functionName+"_top\n"
    if origFirst:
    	origModDecl = findLine(searchstring, origlines[:s])
    	if origModDecl == -1:
    		print "Error: could not find the original module declaration to rename."
    		exit(0) 
    else:
    	origModDecl = findLine(searchstring, origlines[o:])
    	if origModDecl == -1:
    		print "Error: could not find the original module declaration to rename."
    		exit(0) 
    	origModDecl = origModDecl + o 
    del origlines[origModDecl]
    newOrigModDecl = "module debug_top\n"
    origlines.insert(origModDecl, newOrigModDecl)
    		
    	# pSlice circuit
    searchstring = "module "+functionName+"_pSlice_top\n"
    if origFirst:
    	sliceModDecl = findLine(searchstring, origlines[s:])
    	if sliceModDecl == -1:
    		print "Error: could not find the sliceinal module declaration to rename."
    		exit(0) 
    	sliceModDecl = sliceModDecl + s
    else:
    	sliceModDecl = findLine(searchstring, origlines[:o])
    	if sliceModDecl == -1:
    		print "Error: could not find the sliceinal module declaration to rename."
    		exit(0) 
    del origlines[sliceModDecl]
    newOrigModDecl = "module debug_pSlice_top\n"
    origlines.insert(sliceModDecl, newOrigModDecl)
    #----------------------------------------------------------------------------

    outfile.writelines(origlines)
    outfile.close()

if __name__ == "__main__":
            main(sys.argv[1:])
