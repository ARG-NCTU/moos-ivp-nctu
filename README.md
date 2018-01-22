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

### Install Packages
libtiff4-dev is replaced by libtiff5.dev

```
$ sudo apt-get install g++ subversion xterm cmake libfltk1.3-dev freeglut3-dev libpng12-dev libjpeg-dev libxft-dev libxinerama-dev libtiff5-dev
```

### Build
```
$ ./build-moos.sh
$ ./build-ivp.sh
```

### Add Environment Variables (required for RobotX code)

We will do this in moos-ivp/environment.bash

```
export PATH=$HOME"/moos-ivp-nctu/bin:$PATH"
export MOOSIVP_SOURCE_TREE_BASE=$HOME"/moos-ivp/"
```




## 
