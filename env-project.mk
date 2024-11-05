# PROJECT_NAME ?=hello-cpp
# PROJECT_VERSION ?=1.0

###
USE_MAKE=Y
# USE_MAKE=

###
ifeq ($(USE_MAKE),Y)
CONFIG_CMD?=
# BUILD_CMD?=make all COMPILE_ONLY=y
BUILD_CMD?=make all
CLEAN_CMD?=make clean

else
CONFIG_CMD?=
BUILD_CMD?=g++ -c src/main.cpp -o build/main.o
CLEAN_CMD?=rm -rf build/* 
endif


FILE_FOR_NEW_DEFECTS ?=src/main.cpp

## include temparaly values
-include cicd/.project

# delete all object 
# find . -type f \( -name "*.o" -o -name "*.a" -o -name "*.d" -o -name "*.out" -o -name "*.s" \)  -exec rm -vf {} \;
