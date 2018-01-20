# moos-ivp-nctu
A fork from MIT MOOS-IvP Version 17.7

## Development Environment

This is tested in Ubuntu 16.04, ROS Kinectic

## Installation

This is tested in Peter Hunag's VirtualBox image

### Install Packages
libtiff4-dev is replaced by libtiff5.dev

'''
$ sudo apt-get install g++ subversion xterm cmake libfltk1.3-dev freeglut3-dev libpng12-dev libjpeg-dev libxft-dev libxinerama-dev libtiff5-dev
'''

### Build
'''
$ ./build-moos.sh
$ ./build-ivp.sh
'''

### Add Environment Variables (required for RobotX code)

Add to ~/.bashrc

export PATH=$HOME"/moos-ivp-nctu/bin:$PATH"
export MOOSIVP_SOURCE_TREE_BASE=$HOME"/moos-ivp-nctu/"




## 
