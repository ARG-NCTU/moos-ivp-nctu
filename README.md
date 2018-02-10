# moos-ivp-nctu
A fork from MIT MOOS-IvP Version 17.7

## Development Environment

This is tested in Ubuntu 16.04, ROS Kinectic

## Installation

This is tested in 
* Native Ubuntu (Nick's WS3)
* VirtualBox image (Peter Hunag's Ubuntu 16.04)

### clone
The local folder should be named moos-ivp, so that other code can fine it.
Make sure you have ssh-keygen and added the key to github.
```
git clone git@github.com:ARG-NCTU/moos-ivp-nctu.git moos-ivp
```

### Install Packages
libtiff4-dev is replaced by libtiff5.dev

```
./dependencies_common.sh
```

### Build

Tested on workstation, laptop, Pi3 Duckiebot, TX2 (unsuccessful)
```
./build-moos.sh
./build-ivp.sh
```

### Add Environment Variables (required for RobotX code)

We will do this in moos-ivp/environment.bash

## Run the Code

alpha mission
```
$ cd ~/moos-ivp/
$ source environment.bash 
$ cd ivp/missions/s1_alpha
$ pAntler alpha.moos
```

Click Deploy, you will see waypoint navigation with “track point” and “next point”
Click Return, you will go back to the starting points

Read the alpha.bhv, there are
* BHV_Waypoint: define the polygon...
* BHV_ConstantSpeed

Read the alpha.moos
It’s a bit like ros launch file that includes a few processes
pHelmIvP read the alpha.bhv
change to the scene MIT Sailing Pavilion (LatOrigin, LongOrigin, and tiff_file in pMarineViewer)


