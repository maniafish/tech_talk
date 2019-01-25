MAIN_VER=1
GIT_CNT=$(shell git rev-list --count HEAD)
VER=${MAIN_VER}.${GIT_CNT}

all:
	sh build.sh ${VER}
