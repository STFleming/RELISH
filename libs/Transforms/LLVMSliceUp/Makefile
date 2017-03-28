LEVEL=../../..
LIBRARYNAME = LLVMSliceUp
LOADABLE_MODULE = 1
USEDLIBS =

# If we don't need RTTI or EH, there's no reason to export anything
# from the SliceUp plugin.
ifneq ($(REQUIRES_RTTI), 1)
ifneq ($(REQUIRES_EH), 1)
EXPORTED_SYMBOL_FILE = $(PROJ_SRC_DIR)/SliceUp.exports
endif
endif

include $(LEVEL)/Makefile.common
