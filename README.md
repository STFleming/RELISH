```
    ____  ________    _________ __  __
   / __ \/ ____/ /   /  _/ ___// / / /
  / /_/ / __/ / /    / / \__ \/ /_/ / 
 / _, _/ /___/ /____/ / ___/ / __  /  
/_/ |_/_____/_____/___//____/_/ /_/   
```
  
----------------------------------------------

#Runahead Execution of Load Instructions on Sliced Hardware (RELISH)

A High-level synthesis optimisation pass, which automatically constructs helper circuits used to prefetch load instructions.

RELISH is an optional compiler flag for the FPGA high-level synthesis tool LegUp (http://www.legupcomputing.com/). When provided with a hardware function RELISH constructs a helper circuit that can prefetch long latency loads even for irregular access patterns. An analysis called program slicing is used to automatically build the helper circuits by extracting only the computation necessary for the loads requiring prefetching. The result of the analysis is then placed in a redundant hardware thread where it can run ahead of the main computation and store the result of the loads in a prefetch buffer. On average RELISH increases the resource utilisation of the generated circuit by 1.15x while improving performance by 1.38x. 

More information can be found in papers/fccm2017.pdf

#Using the dockerfile

The easiest way to get started experimenting with RELISH is to use the provided Dockerfile.
This file constructs a docker container,  downloading and installing LegUp-4.0, and patching in RELISH.
How to install docker can be located here:  https://docs.docker.com/engine/getstarted/step_one/

To build the container image run the following command in the root folder:
`docker build - "relish_container" .`
This might take a while to build.

To launch an instance of the container image and open an interactive shell type:
`docker run -ti relish_container /bin/bash`

#Running example builds

Example projects and makefiles are provided in the `examples/` directory.
To construct one of the examples type `make all` in the appropriate directory.

For the examples the function to be accelerated is specified in `config.tcl` as the function to be sliced is specified in `sliceConfig.tcl`. The make file, applies the LegUp hybrid parallel flow to the source along with RELISH and generates AXI wrapper logic for use in a Xilinx system. 

The resulting Xilinx build files are included in the outputted folder `AXIWrapper/`. The files in this folder can be used in Vivado to build a working system through the following two commands in the AXIWrapper directory: ( Vivado is not provided in the Docker image, so this will need to be performed outside the container.)
* `vivado -mode batch -source _packageIPScript.tcl` -- which packages the generated hardware into a IP core
* `vivado -mode batch -source vivado_build.tcl` -- which builds a Zynq system (Zedboard) using the generated IP core.
  
To build a new project in the example folder, the following things must be set:
* `config.tcl` should specify the name of the function to accelerate
* `sliceConfig.tcl` should specify the name of the function to be sliced
* The `ACCELS` variable in the Makefile in the examples directory should specify the name of the function being accelerated and sliced, along with the name of the sliced version of the function (default suffix is '_pSlice'). For example in dotproduct, `ACCELS="dotproduct,dotproduct_pSlice"` 

------------------------------------------------------

Any questions or queries feel free to contact me on: shane.fleming06@imperial.ac.uk
