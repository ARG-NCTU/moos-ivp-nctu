#!/bin/bash
set -e

if [[ `id -u` -eq 0 ]] ; then
    echo "Do not run this with sudo (do not run random things with sudo!)." ;
    exit 1 ;
fi

set -x


sudo apt install -y \
	g++ \
	subversion \
	xterm \
	cmake \
	libfltk1.3-dev \
	freeglut3-dev \
	libpng12-dev \
	libjpeg-dev \
	libxft-dev \
	libxinerama-dev \
	libtiff5-dev

