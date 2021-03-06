#!/bin/sh 

WARP=1
HELP="no"
JUST_BUILD="no"
BAD_ARGS=""

#-------------------------------------------------------
#  Part 1: Check for and handle command-line arguments
#-------------------------------------------------------
let COUNT=0
for ARGI; do
    UNDEFINED_ARG=$ARGI
    if [ "${ARGI:0:6}" = "--warp" ] ; then
	WARP="${ARGI#--warp=*}"
	UNDEFINED_ARG=""
    fi
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
	HELP="yes"
	UNDEFINED_ARG=""
    fi
    # Handle Warp shortcut
    if [ "${ARGI//[^0-9]/}" = "$ARGI" -a "$COUNT" = 0 ]; then 
        WARP=$ARGI
        let "COUNT=$COUNT+1"
        UNDEFINED_ARG=""
    fi
    if [ "${ARGI}" = "--just_build" ] ; then
	JUST_BUILD="yes"
	UNDEFINED_ARG=""
    fi
    if [ "${UNDEFINED_ARG}" != "" ] ; then
	BAD_ARGS=$UNDEFINED_ARG
    fi
done

if [ "${BAD_ARGS}" != "" ] ; then
    printf "Bad Argument: %s \n" $BAD_ARGS
    exit 0
fi

if [ "${HELP}" = "yes" ]; then
    printf "%s [SWITCHES]         \n" $0
    printf "Switches:             \n" 
    printf "  --warp=WARP_VALUE   \n" 
    printf "  --just_build        \n" 
    printf "  --help, -h          \n" 
    exit 0;
fi

# Second check that the warp argument is numerical
if [ "${WARP//[^0-9]/}" != "$WARP" ]; then 
    printf "Warp values must be numerical. Exiting now."
    exit 127
fi

#-------------------------------------------------------
#  Part 2: Create the .moos and .bhv files. 
#-------------------------------------------------------

VNAME1="vehicle1"  # Vehicle 1 Community
VPORT1="9201"
VNAME2="vehicle2"  # Vehicle 2 Community
VPORT2="9202"
SNAME="shoreside"  # Shoreside Community
SPORT="9200"
START_POS1="0,0"         # Vehicle 1 Behavior configurations
LOITER_POS1="x=-40,y=-100"
START_POS2="20,0"        # Vehicle 2 Behavior configurations
LOITER_POS2="x=30,y=-120"


nsplug meta_vehicle.moos targ_vehicle1.moos -f WARP=$WARP       \
   VNAME1=$VNAME1 VNAME2=$VNAME2 VPORT1=$VPORT1 VPORT2=$VPORT2  \
   VNAME=$VNAME1 VPORT=$VPORT1 SPORT=$SPORT SNAME=$SNAME        \
   START_POS=$START_POS1

nsplug meta_vehicle.moos targ_vehicle2.moos -f WARP=$WARP       \
   VNAME1=$VNAME1 VNAME2=$VNAME2 VPORT1=$VPORT1 VPORT2=$VPORT2  \
   VNAME=$VNAME2 VPORT=$VPORT2 SPORT=$SPORT SNAME=$SNAME        \
   START_POS=$START_POS2

nsplug meta_shoreside.moos targ_shoreside.moos -f WARP=$WARP    \
   VNAME1=$VNAME1 VNAME2=$VNAME2 VPORT1=$VPORT1 VPORT2=$VPORT2  \
   SPORT=$SPORT SNAME=$SNAME

nsplug meta_vehicle.bhv targ_vehicle1.bhv -f VNAME=$VNAME1      \
    START_POS=$START_POS1 LOITER_POS=$LOITER_POS1       

nsplug meta_vehicle.bhv targ_vehicle2.bhv -f VNAME=$VNAME2      \
    START_POS=$START_POS1 LOITER_POS=$LOITER_POS2       

if [ ${JUST_BUILD} = "yes" ] ; then
    exit 0
fi

#-------------------------------------------------------
#  Part 3: Launch the processes
#-------------------------------------------------------

printf "Launching $VNAME1 MOOS Community (WARP=%s) \n" $WARP
pAntler targ_vehicle1.moos >& /dev/null &
sleep 1
printf "Launching $VNAME2 MOOS Community (WARP=%s) \n" $WARP
pAntler targ_vehicle2.moos >& /dev/null &
sleep 1
printf "Launching $SNAME MOOS Community (WARP=%s) \n"  $WARP
pAntler targ_shoreside.moos >& /dev/null &
printf "Done \n"

#-------------------------------------------------------
#  Part 4: Exiting and/or killing the simulation
#-------------------------------------------------------

ANSWER="0"
while [ "${ANSWER}" != "1" -a "${ANSWER}" != "2" ]; do
    printf "Now what? (1) Exit script (2) Exit and Kill Simulation \n"
    printf "> "
    read ANSWER
done

# %1, %2, %3 matches the PID of the first three jobs in the active
# jobs list, namely the three pAntler jobs launched in Part 3.
if [ "${ANSWER}" = "2" ]; then
    printf "Killing all processes ... \n"
    kill %1 %2 %3 
    printf "Done killing processes.   \n"
fi


