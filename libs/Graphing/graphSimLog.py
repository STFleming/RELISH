import sys, getopt
import os
import shutil
import re

def main(argv):
	simlog = ''
	startcycle = 0
	endcycle = 0
	try:
		opts, args = getopt.getopt(argv, "hi:s:e:", ["input=", "start=", "end="])
	except getopt.GetoptError:
		print 'Usage: python graphSimLog.py --input sim.log --start startcycle --end endcycle'
		sys.exit(2)

	for opt, arg in opts:
		if opt == '-h':
			print 'Usage: python graphSimLog.py --input sim.log --start startcycle --end endcycle'
			sys.exit()
		elif opt in ("-i", "--input"):
			simlog = arg 
		elif opt in ("-s", "--start"):
			startcycle = int(arg) 
		elif opt in ("-e", "--end"):
			endcycle = int(arg) 
    
	logInput = open(simlog, 'r').readlines() 
	jsonout = open("data.json", 'w')	

	events = []
	#We need to find all load printfs: see example below 
	## Cycle:                29727 Time:               594590    ListAverage_pSlice - LD  0x2000000
	for line in logInput:
		regex = "# Cycle:\W*([0-9]+)\W+Time:\W*[0-9]+\W*([A-z]+)\W-\W([A-z]+[0-9]*)\W+0x([A-z0-9]+)"
		m = re.search(regex,line)
		if m:
			event_element =[]
			event_element.append(int(m.group(1)))
			sliceRE = "\w*_pSlice"
			ms = re.search(sliceRE, m.group(2))
			if ms:
				event_element.append(True)
			else:
				event_element.append(False)
			event_element.append(m.group(3))
			event_element.append(m.group(4))

			if startcycle != 0 or endcycle != 0:
				if event_element[0] > startcycle and event_element[0] < endcycle:
					events.append(event_element)
			else:
				events.append(event_element)
		
	links = []
	pos = 0
	for event in events:
		if event[1]:
			addr = event[3]
			ldName = event[2]
			linkStart = event[0]
			found = False
			for linkSearch in events:
				if not linkSearch[1]: #Pslice event
					if addr == linkSearch[3]:
						if ldName == linkSearch[2]:
							if not found:
								if linkSearch[0] == linkStart:
									found = True	
								if linkSearch[0] > linkStart:
									add_link =[]
									add_link.append(linkStart)
									add_link.append(linkSearch[0])
									links.append(add_link)
									found = True


#Write data.json file
	outs = "{\n"

	#Write out the nodes
	outs += "\t\"nodes\":[\n"
	for e in events:
		outs += "\t\t{\"name\":\""+e[2]
		if e[1]:
			outs += "\",\"group\":0"
		else:
			outs += "\",\"group\":1"
		outs += ",\"time\":"+str(e[0]) 
		outs += ",\"addr\":\""+str(e[3])+"\""
		outs += "},\n"
	outs = outs[:-2]	
	outs += "\n\t],\n"

	#write out the links
	outs += "\t\"links\":[\n"
	if links:
		for l in links:
			outs += "\t\t{\"source\":" +str(l[0])+",\"target\":"+str(l[1])+",\"value\":1},\n"		
		outs = outs[:-2]
	outs += "\n\t],\n"

	#Write out startTime and endTime
	outs += "\t\"startTime\":" + str(events[0][0]) + ",\n"
	outs += "\t\"endTime\":" + str(events[-1][0]) + ",\n"
	outs += "\t\"startLink\":" +str(links[0][1] - links[0][0])+",\n"
	outs += "\t\"endLink\":"+str(links[-1][1] - links[-1][0])+"\n"
	outs += "}"
	jsonout.write(outs)
	jsonout.close()		

	python_dir =  os.path.dirname(os.path.realpath(__file__))
	shutil.copytree(python_dir + "/_d3graph", "./_d3graph")
	shutil.move("./data.json", "./_d3graph/data.json")

if __name__ == "__main__":
            main(sys.argv[1:])
