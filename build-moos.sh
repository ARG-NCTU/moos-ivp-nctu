#!/bin/bash

INVOC_ABS_DIR="$(pwd)"
SCRIPT_ABS_DIR="$(cd $(dirname "$0") && pwd -P)"
MOOS_SRC_DIR="${SCRIPT_ABS_DIR}/MOOS"
BUILD_ABS_DIR="${SCRIPT_ABS_DIR}/build/MOOS"
mkdir -p "${BUILD_ABS_DIR}"


BUILD_TYPE="Release"
BUILD_OPTIM="yes"
CMD_ARGS="-j$(getconf _NPROCESSORS_ONLN)"
BUILD_BOT_CODE_ONLY="OFF"

for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
        printf "%s [SWITCHES]  \n" $0
        printf "  --help, -h                                   \n"
        printf "  --debug, -d                                  \n"
        printf "  --release, -r                                \n"
        printf "Any other switches passed directly to \"make\" \n"
        printf "Recommended:                                   \n"
        printf " -jN    Speed up compile on multi-core machines. \n"
        printf " -k     Keep building after failed component.    \n"
	printf " -m,    Only build minimal robot apps            \n"
        printf " clean  Clean/remove any previous build.         \n"
        exit 0;
    elif [ "${ARGI}" = "--debug" -o "${ARGI}" = "-d" ] ; then
        BUILD_TYPE="Debug"
    elif [ "${ARGI}" = "--release" -o "${ARGI}" = "-r" ] ; then
        BUILD_TYPE="Release"
    elif [ "${ARGI}" = "--minrobot" -o "${ARGI}" = "-m" ] ; then
        BUILD_BOT_CODE_ONLY="ON"
    else
	CMD_ARGS=$CMD_ARGS" "$ARGI
    fi
done

echo "  SCRIPT_ABS_DIR: " ${SCRIPT_ABS_DIR}

# Setup C and C++ Compiler flags for Mac and Linux. 
MOOS_CXX_FLAGS="-Wall -Wextra -Wno-unused-parameter -pedantic -fPIC"
if [ "${BUILD_OPTIM}" = "yes" ] ; then
    MOOS_CXX_FLAGS=$MOOS_CXX_FLAGS" -Os"
fi

#-------------------------------------------------------------------
# Clean up old files left behind from in-source builds. 
#-------------------------------------------------------------------

if [ -e "${MOOS_SRC_DIR}/proj-4.8.0/Makefile" ] ; then
    $(cd "${MOOS_SRC_DIR}/proj-4.8.0/" && make distclean) >& /dev/null
fi
if [ -d "${MOOS_SRC_DIR}/proj-4.8.0/bin" ] ; then
    rm -rf "${MOOS_SRC_DIR}/proj-4.8.0/bin" >& /dev/null
fi
if [ -d "${MOOS_SRC_DIR}/proj-4.8.0/include" ] ; then
    rm -rf "${MOOS_SRC_DIR}/proj-4.8.0/include" >& /dev/null
fi
if [ -d "${MOOS_SRC_DIR}/proj-4.8.0/lib" ] ; then
    rm -rf "${MOOS_SRC_DIR}/proj-4.8.0/lib" >& /dev/null
fi
if [ -d "${MOOS_SRC_DIR}/proj-4.8.0/share" ] ; then
    rm -rf "${MOOS_SRC_DIR}/proj-4.8.0/share" >& /dev/null
fi

if [ -d "${MOOS_SRC_DIR}/MOOSCore/lib" ] ; then
    rm -rf "${MOOS_SRC_DIR}/MOOSCore/lib" >& /dev/null
fi
if [ -d "${MOOS_SRC_DIR}/MOOSGeodesy/lib" ] ; then
    rm -rf "${MOOS_SRC_DIR}/MOOSGeodesy/lib" >& /dev/null
fi
if [ -d "${MOOS_SRC_DIR}/MOOSToolsUI/lib" ] ; then
    rm -rf "${MOOS_SRC_DIR}/MOOSToolsUI/lib" >& /dev/null
fi

find "${MOOS_SRC_DIR}/" -type d -name "CMakeFiles" -exec rm -rf {} +
find "${MOOS_SRC_DIR}/" -type f -name "CMakeCache.txt" -delete
find "${MOOS_SRC_DIR}/" -type f -name "cmake_install.cmake" -delete
find "${MOOS_SRC_DIR}/" -type f -name "Makefile" -delete
find "${MOOS_SRC_DIR}/" -type f -name "UseMOOS*.cmake" -delete
find "${MOOS_SRC_DIR}/" -type f -name "MOOS*Config*.cmake" -delete
find "${MOOS_SRC_DIR}/" -type f -name "*.o" -delete
find "${MOOS_SRC_DIR}/" -type f -name "*.lo" -delete

#===================================================================
# Part #1:  BUILD CORE
#      -DUPDATE_GIT_VERSION_INFO=OFF                          \
#===================================================================
mkdir -p "${BUILD_ABS_DIR}/MOOSCore"
cd "${BUILD_ABS_DIR}/MOOSCore"

echo "Invoking cmake..." `pwd`
cmake -DENABLE_EXPORT=ON                                       \
      -DUSE_ASYNC_COMMS=ON                                     \
      -DTIME_WARP_AGGLOMERATION_CONSTANT=0.4                   \
      -DCMAKE_BUILD_TYPE=${BUILD_TYPE}                         \
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="${SCRIPT_ABS_DIR}/bin" \
      -DCMAKE_CXX_FLAGS="${MOOS_CXX_FLAGS}"                    \
      "${MOOS_SRC_DIR}/MOOSCore"                               \
  && echo "" && echo "Invoking make..." `pwd` && echo ""       \
  && make  ${CMD_ARGS}

if [ $? -ne 0 ] ; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "ERROR! Failed to build MOOSCore"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit -1
fi


#===================================================================
# Part #2:  BUILD ESSENTIALS
#===================================================================
mkdir -p "${BUILD_ABS_DIR}/MOOSEssentials"
cd "${BUILD_ABS_DIR}/MOOSEssentials"

echo "Invoking cmake..." `pwd`
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE}                          \
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="${SCRIPT_ABS_DIR}/bin"  \
      -DCMAKE_CXX_FLAGS="${MOOS_CXX_FLAGS}"                     \
      "${MOOS_SRC_DIR}/MOOSEssentials"                          \
  && echo"" && echo "Invoking make..." `pwd` && echo""          \
  && make ${CMD_ARGS}

if [ $? -ne 0 ] ; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "ERROR! Failed to build MOOSEssentials"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit -1
fi

#===================================================================
# Part #3:  BUILD MOOS GUI TOOLS
#===================================================================

printf "+++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "MOOS_BUILD_BOT_CODE_ONLY: ${BUILD_BOT_CODE_ONLY}   \n"
printf "+++++++++++++++++++++++++++++++++++++++++++++++++++\n"
if [ "${BUILD_BOT_CODE_ONLY}" = "OFF" ] ; then

    mkdir -p "${BUILD_ABS_DIR}/MOOSToolsUI"
    cd "${BUILD_ABS_DIR}/MOOSToolsUI"
    
    echo "Invoking cmake..." `pwd`
    cmake -DBUILD_CONSOLE_TOOLS=ON                               \
	-DBUILD_GRAPHICAL_TOOLS=ON                               \
	-DBUILD_UPB=ON                                           \
	-DCMAKE_BUILD_TYPE=${BUILD_TYPE}                         \
	-DCMAKE_RUNTIME_OUTPUT_DIRECTORY="${SCRIPT_ABS_DIR}/bin" \
	-DCMAKE_CXX_FLAGS="${MOOS_CXX_FLAGS}"                    \
        "${MOOS_SRC_DIR}/MOOSToolsUI"                            \
      && echo "" && echo "Invoking make..." `pwd` && echo ""     \
      && make ${CMD_ARGS}    
    if [ $? -ne 0 ] ; then
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "ERROR! Failed to build MOOSToolsUI"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        exit -1
    fi
fi




#===================================================================
# Part #4:  BUILD PROJ4
#===================================================================
mkdir -p "${BUILD_ABS_DIR}/proj-4.8.0"
cd "${BUILD_ABS_DIR}/proj-4.8.0"

# TODO: This will always build PROJ4, even if local OS install performed.
if [ ! -e lib/libproj.a ]; then
  echo "Building Proj4. MOOSGeodesy now uses Proj4 with MOOSGeodesy wrapper"
  "${MOOS_SRC_DIR}/proj-4.8.0/configure" --with-jni=no --enable-shared=no --enable-static=yes --with-pic --build=aarch64-unknown-linux-gnu \
    && make -j$(getconf _NPROCESSORS_ONLN)           \
    && make install                                  \
    && echo "Done Building Proj4."
  if [ $? -ne 0 ] ; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "ERROR! Failed to build PROJ4"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit -1
  fi
fi


#===================================================================
# Part #5:  BUILD MOOS GEODESY
#===================================================================
mkdir -p "${BUILD_ABS_DIR}/MOOSGeodesy"
cd "${BUILD_ABS_DIR}/MOOSGeodesy"

PROJ4_INCLUDE_DIR="${BUILD_ABS_DIR}/proj-4.8.0/include"
PROJ4_LIB_DIR="${BUILD_ABS_DIR}/proj-4.8.0/lib"

echo "PROJ4 LIB DIR: " $PROJ4_LIB_DIR


echo "Invoking cmake..." `pwd`
cmake -DCMAKE_CXX_FLAGS="${MOOS_CXX_FLAGS}"                    \
      -DPROJ4_INCLUDE_DIRS=${PROJ4_INCLUDE_DIR}                \
      -DPROJ4_LIB_PATH=${PROJ4_LIB_DIR}                        \
      "${MOOS_SRC_DIR}/MOOSGeodesy"                            \
  && echo "" && echo "Invoking make..." `pwd` && echo ""       \
  && make ${CMD_ARGS}

if [ $? -ne 0 ] ; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "ERROR! Failed to build MOOSGeodesy"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit -1
fi


cd ${INVOC_ABS_DIR}

