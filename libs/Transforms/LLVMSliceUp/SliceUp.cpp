//===- SliceUp.cpp - Example code from "Writing an LLVM Pass" ---------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements two versions of the LLVM "SliceUp World" pass described
// in docs/WritingAnLLVMPass.html
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/Statistic.h"
#include "llvm/IR/Function.h"
#include "llvm/Pass.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/raw_ostream.h"
#include "ISlice.h"
#include "Slice.h"
#include "MemSlice.h"
#include "CFSlice.h"
#include "SliceHelpers.h"
#include "LoadRunaheadAnalysis.h"
#include <fstream>
#include <string>

using namespace llvm;
 
namespace {
  struct SliceUp : public FunctionPass {
    static char ID; // Pass identification, replacement for typeid
    SliceUp() : FunctionPass(ID) {}

    bool runOnFunction(Function &F) override {

	std::ifstream funcFile("sliceConfig.tcl");
	std::string line;
	getline(funcFile, line);
	if(F.getName().str() == line)
	{
		std::ofstream analysisResults;	
		analysisResults.open(F.getName().str() + "_analysisResults.csv");
		errs() << "Found our function!  " << F.getName().str() <<" \n";

		labelBB(&F);
		nameAllLoadOps(&F);
		Function *sF = replicateFunction(&F);

		LoadRunaheadAnalysis mem_analysis(sF);
		mem_analysis.printAnalysis(analysisResults);
		MemSlice loadSlices = mem_analysis.mergeAll();
		analysisResults << "\n\n";
		loadSlices.printCriterion(analysisResults);

		ISlice inv_loadSlices(sF);
		inv_loadSlices.inverse(&loadSlices);

		//loadSlices.print();
		
		analysisResults << "\n\nOriginal: " << functionInstructionCount(&F) <<"\n";
		analysisResults << "Slice: " << loadSlices.instructionCount() <<"\n";
		analysisResults << "Inverse: " << inv_loadSlices.instructionCount() <<"\n";
		analysisResults.close();

		removeSlice(sF, &inv_loadSlices); //Remove the inverse from the program leaving just the wanted slice behind 		
		pruneUnusedBlocks(sF, &loadSlices); //Remove all unused BasicBlocks in the LoadSlice
		//functionSanityCheck(sF); //debugging the newly minted p-slice function
	
		printAllLoadOps(sF);
		printAllLoadOps(&F);
		callReplicantFunction(&F, sF);
	}
	


      return true;
    }

    bool doFinalization(Module &M) override {
	return true;
    } 

  };
}

char SliceUp::ID = 0;
static RegisterPass<SliceUp> X("SliceUp", "SliceUp Pass");

