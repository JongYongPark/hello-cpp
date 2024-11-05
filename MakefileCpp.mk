#$(warning A top-level warning)

#### PROJECT SETTINGS ####
# The name of the executable to be created
#BIN_NAME := hello
BIN_NAME ?= hello

# https://stackoverflow.com/questions/2965829/what-does-cc-in-a-makefile-mean
# Usually, CC=cc by default. Then on Ubuntu 14.04 for e.g., cc is usually a symlink to gcc.

# https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html
# 
#CC
#Program for compiling C programs; default ‘cc’.
#
#CXX
#Program for compiling C++ programs; default ‘g++’.
#
#CPP
#Program for running the C preprocessor, with results to standard output; default ‘$(CC) -E’. 

# Compiler used
#GCC_PREFIX ?=
CXX?= g++
CC?= gcc
#CXX ?=clang++
#CC ?=clangc
# Extension of source files used in the project
JAVAC?= javac
SRC_EXT = cpp
SRC_EXT_C = c
SRC_EXT_JAVA = java
# Path to the source directory, relative to the makefile
SRC_PATH ?= .
# Space-separated pkg-config libraries used by this project
LIBS =
# General compiler flags
EXTRA_CFLAGS ?=
EXTRA_CXXFLAGS ?=
COMPILE_FLAGS ?= -std=c++14 -Wall -Wextra -g $(EXTRA_CXXFLAGS)
# In versions pre-G++ 4.7, you'll have to use -std=c++0x, for more recent versions you can use -std=c++11.
#COMPILE_FLAGS = -std=c++0x -Wall -Wextra -g
COMPILE_FLAGS_C ?= -std=c99 -Wall -Wextra -g $(EXTRA_CFLAGS)
# Additional release-specific flags
RCOMPILE_FLAGS = -D NDEBUG
# Additional debug-specific flags
DCOMPILE_FLAGS = -D DEBUG
# Add additional include paths
#EXTRA_INC ?=
INCLUDES = -I $(SRC_PATH)  $(EXTRA_INC)

# General linker settings
LINK_FLAGS =
# Additional release-specific linker settings
RLINK_FLAGS =
# Additional debug-specific linker settings
DLINK_FLAGS =
# Destination directory, like a jail or mounted system
DESTDIR = ./out
# Install path (bin/ is appended automatically)
INSTALL_PREFIX = usr/local
#### END PROJECT SETTINGS ####

# Generally should not need to edit below this line

# Obtains the OS type, either 'Darwin' (OS X) or 'Linux'
UNAME_S:=$(shell uname -s)

# Function used to check variables. Use on the command line:
# make print-VARNAME
# Useful for debugging and adding features
print-%: ; @echo $*=$($*)

# Shell used in this makefile
# bash is used for 'echo -en'
SHELL = /bin/bash
# Clear built-in rules
.SUFFIXES:
# Programs for installation
INSTALL = install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644

#NO_TIME ?=false
NO_TIME ?=true
GEN_BIN ?=
# Append pkg-config specific libraries if need be
ifneq ($(LIBS),)
	COMPILE_FLAGS += $(shell pkg-config --cflags $(LIBS))
	LINK_FLAGS += $(shell pkg-config --libs $(LIBS))
endif

# Verbose option, to output compile and link commands
#export V := true 
#export CMD_PREFIX := @
#ifeq ($(V),true)
#	CMD_PREFIX :=
#endif

V := true 
ifeq ($(V),true)
	CMD_PREFIX :=
endif

.PHONY: all
#all: clean release
# remove clean 
all: debug

# Combine compiler and linker flags
release: export CXXFLAGS := $(CXXFLAGS) $(COMPILE_FLAGS) $(RCOMPILE_FLAGS)
release: export CFLAGS := $(CFLAGS) $(COMPILE_FLAGS_C) $(RCOMPILE_FLAGS)
release: export LDFLAGS := $(LDFLAGS) $(LINK_FLAGS) $(RLINK_FLAGS)
debug: export CXXFLAGS := $(CXXFLAGS) $(COMPILE_FLAGS) $(DCOMPILE_FLAGS)
debug: export CFLAGS := $(CFLAGS) $(COMPILE_FLAGS_C) $(DCOMPILE_FLAGS)
debug: export LDFLAGS := $(LDFLAGS) $(LINK_FLAGS) $(DLINK_FLAGS)

# Build and output paths
release: export BUILD_PATH := build/release
release: export BIN_PATH := bin/release
debug: export BUILD_PATH := build/debug
debug: export BIN_PATH := bin/debug
install: export BIN_PATH := bin/release

# Find all source files in the source directory, sorted by most
# recently modified
ifeq ($(UNAME_S),Darwin)
	SOURCES = $(shell find $(SRC_PATH) -name '*.$(SRC_EXT)' | sort -k 1nr | cut -f2-)
else
	SOURCES = $(shell find $(SRC_PATH) -name '*.$(SRC_EXT)' -printf '%T@\t%p\n' \
						| sort -k 1nr | cut -f2-)
endif

# fallback in case the above fails
rwildcard = $(foreach d, $(wildcard $1*), $(call rwildcard,$d/,$2) \
						$(filter $(subst *,%,$2), $d))
ifeq ($(SOURCES),)
	SOURCES := $(call rwildcard, $(SRC_PATH)/, *.$(SRC_EXT))
endif

ifeq ($(SOURCES_C),)
	SOURCES_C := $(call rwildcard, $(SRC_PATH)/, *.$(SRC_EXT_C))
endif

ifeq ($(SOURCES_JAVA),)
	SOURCES_JAVA := $(call rwildcard, $(SRC_PATH)/, *.$(SRC_EXT_JAVA))
endif



# Set the object file names, with the source directory stripped
# from the path, and the build path prepended in its place
#OBJECTS = $(SOURCES:$(SRC_PATH)/%.$(SRC_EXT)=$(BUILD_PATH)/%.o)
OBJECTS = $(SOURCES:$(SRC_PATH)/%.$(SRC_EXT)=$(BUILD_PATH)/%.o)  $(SOURCES_C:$(SRC_PATH)/%.$(SRC_EXT_C)=$(BUILD_PATH)/%.o)
#OBJECTS_C = $(SOURCES_C:$(SRC_PATH)/%.$(SRC_EXT_C)=$(BUILD_PATH)/%.o)

#classfiles  = $(SOURCES_JAVA:.java=.class)
classfiles  = $(SOURCES_JAVA:$(SRC_PATH)/%.$(SRC_EXT_JAVA)=$(BUILD_PATH)/%.class)
ifndef classpath
export classpath = $(BUILD_PATH)
endif

# Set the dependency files that will be used to add header dependencies
DEPS = $(OBJECTS:.o=.d)

# Macros for timing compilation
ifeq ($(NO_TIME),false)
ifeq ($(UNAME_S),Darwin)
	CUR_TIME = awk 'BEGIN{srand(); print srand()}'
	TIME_FILE = $(dir $@).$(notdir $@)_time
	START_TIME = $(CUR_TIME) > $(TIME_FILE)
	END_TIME = read st < $(TIME_FILE) ; \
		$(RM) $(TIME_FILE) ; \
		st=$$((`$(CUR_TIME)` - $$st)) ; \
		echo $$st
else
	TIME_FILE = $(dir $@).$(notdir $@)_time
	START_TIME = date '+%s' > $(TIME_FILE)
	END_TIME = read st < $(TIME_FILE) ; \
		$(RM) $(TIME_FILE) ; \
		st=$$((`date '+%s'` - $$st - 86400)) ; \
		echo `date -u -d @$$st '+%H:%M:%S'`
endif
endif

# Version macros
# Comment/remove this section to remove versioning
USE_VERSION := false
# If this isn't a git repo or the repo has no tags, git describe will return non-zero
ifeq ($(shell git describe > /dev/null 2>&1 ; echo $$?), 0)
	USE_VERSION := true
	VERSION := $(shell git describe --tags --long --dirty --always | \
		sed 's/v\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\)-\?.*-\([0-9]*\)-\(.*\)/\1 \2 \3 \4 \5/g')
	VERSION_MAJOR := $(word 1, $(VERSION))
	VERSION_MINOR := $(word 2, $(VERSION))
	VERSION_PATCH := $(word 3, $(VERSION))
	VERSION_REVISION := $(word 4, $(VERSION))
	VERSION_HASH := $(word 5, $(VERSION))
	VERSION_STRING := \
		"$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH).$(VERSION_REVISION)-$(VERSION_HASH)"
	override CXXFLAGS := $(CXXFLAGS) \
		-D VERSION_MAJOR=$(VERSION_MAJOR) \
		-D VERSION_MINOR=$(VERSION_MINOR) \
		-D VERSION_PATCH=$(VERSION_PATCH) \
		-D VERSION_REVISION=$(VERSION_REVISION) \
		-D VERSION_HASH=\"$(VERSION_HASH)\"
	override CFLAGS := $(CFLAGS) \
		-D VERSION_MAJOR=$(VERSION_MAJOR) \
		-D VERSION_MINOR=$(VERSION_MINOR) \
		-D VERSION_PATCH=$(VERSION_PATCH) \
		-D VERSION_REVISION=$(VERSION_REVISION) \
		-D VERSION_HASH=\"$(VERSION_HASH)\"		
endif

# Standard, non-optimized release build
.PHONY: release
release: dirs
ifeq ($(USE_VERSION), true)
	@echo "Beginning release build v$(VERSION_STRING)"
else
	@echo "Beginning release build"
endif
	@$(START_TIME)
	@$(MAKE) all_object --no-print-directory
	@echo -n "Total build time: "
	@$(END_TIME)

# Debug build for gdb debugging
.PHONY: debug
debug: dirs
ifeq ($(USE_VERSION), true)
	@echo "Beginning debug build v$(VERSION_STRING)"
else
	@echo "Beginning debug build"
endif
	@$(START_TIME)
	@$(MAKE) all_object --no-print-directory
	@echo -n "Total build time: "
	@$(END_TIME)

# Create the directories used in the build
.PHONY: dirs
dirs:
	@echo "Creating directories for c/cpp"
	@echo "<SOURCES>===$(SOURCES)==="
	@echo "<SOURCES_C>===$(SOURCES_C)==="
	@echo "<SOURCES_JAVA>===$(SOURCES_JAVA)==="
	@echo "<OBJECTS>===$(OBJECTS)==="
	@echo "<BIN_PATH>===$(BIN_PATH)==="
	@mkdir -p $(BIN_PATH)
ifneq ($(strip $(OBJECTS)),)
	@mkdir -p $(dir $(OBJECTS))
else
	@echo "No C/CPP source files"
	@mkdir -p $(BUILD_PATH)
endif	
	

# Installs to the set path
.PHONY: install
install:
	@echo "Installing to $(DESTDIR)$(INSTALL_PREFIX)/bin"
	@$(INSTALL_PROGRAM) $(BIN_PATH)/$(BIN_NAME) $(DESTDIR)$(INSTALL_PREFIX)/bin

# Uninstalls the program
.PHONY: uninstall
uninstall:
	@echo "Removing $(DESTDIR)$(INSTALL_PREFIX)/bin/$(BIN_NAME)"
	@$(RM) $(DESTDIR)$(INSTALL_PREFIX)/bin/$(BIN_NAME)

# Removes all build files
.PHONY: clean
clean:
	@echo "Deleting $(BIN_NAME) symlink"
	@$(RM) $(BIN_NAME);true
	@echo "Deleting directories"
	@$(RM) -r build
	@$(RM) -r bin

# Main rule, checks the executable and symlinks to the output
all_object: $(BIN_PATH)/$(BIN_NAME)
	@echo "Making symlink: $(BIN_NAME) -> $<"
	@$(RM) $(BIN_NAME)
	@ln -s $(BIN_PATH)/$(BIN_NAME) $(BIN_NAME)

run: 
	./$(BIN_NAME)
	
make_test:
	# All variable in Makefile is string. int is not possible 
	# A variable is a name defined in a makefile to represent a string of text, called the variable’s value. These values are substituted by explicit request into targets, prerequisites, recipes, and other parts of the makefile. (In some other versions of make, variables are called macros.)
	#result=$(if $(filter-out y,${GEN_BIN}),true,false)
	result=$(if $(filter y,${GEN_BIN}),true,false)
	echo "result = $(result)" 
ifeq ($(result),true) 
	echo "compile + link"
else
	echo "compile only"
endif
	echo "GEN_BIN = $(GEN_BIN)" 
ifneq ($(GEN_BIN),Y) 
	echo "compile only"
else
	echo "compile + link"
endif	
	
# Link the executable
$(BIN_PATH)/$(BIN_NAME): $(OBJECTS)  $(classfiles)
ifneq ($(GEN_BIN),Y) 
	@echo "Compile Only, No Linking"
else
	@echo "Linking: $@"
	@$(START_TIME)
	$(CMD_PREFIX)$(CXX) $(OBJECTS) $(LDFLAGS) -o $@
	@echo -en "\t Link time: "
	@$(END_TIME)
endif	


# Add dependency files, if they exist
-include $(DEPS)

# Source file rules
# After the first compilation they will be joined with the rules from the
# dependency files to provide header dependencies

# https://stackoverflow.com/questions/2670130/make-how-to-continue-after-a-command-fails
# x $(CMD_PREFIX)$(CXX) $(CXXFLAGS) $(INCLUDES) -MP -MMD -c $< -o $@  || true
# -$(CMD_PREFIX)$(CXX) $(CXXFLAGS) $(INCLUDES) -MP -MMD -c $< -o $@  
$(BUILD_PATH)/%.o: $(SRC_PATH)/%.$(SRC_EXT)
	@echo "Compiling CPP : $< -> $@"
	@$(START_TIME)
	-$(CMD_PREFIX)$(CXX) $(CXXFLAGS) $(INCLUDES) -MP -MMD -c $< -o $@  
	@echo -en "\t Compile time: "
	@$(END_TIME)
	
$(BUILD_PATH)/%.o: $(SRC_PATH)/%.$(SRC_EXT_C)
	@echo "Compiling C: $< -> $@"
	@$(START_TIME)
	$(CMD_PREFIX)$(CC) $(CFLAGS) $(INCLUDES) -MP -MMD -c $< -o $@
	@echo -en "\t Compile time: "
	@$(END_TIME)	
	
	
#%.class: %.java 
#    $(JAVAC) -d . -classpath . $<	

$(BUILD_PATH)/%.class: $(SRC_PATH)/%.$(SRC_EXT_JAVA)
	echo "Compiling Java: $< -> $@"

	@$(START_TIME)
	#$(CMD_PREFIX)$(CC) $(CFLAGS) $(INCLUDES) -MP -MMD -c $< -o $@
	#$(JAVAC) -d . -classpath . $<
	$(JAVAC) -d $(classpath) -classpath $(classpath) $<
	@echo -en "\t Compile time: "
	@$(END_TIME)		
