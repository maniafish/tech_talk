MAIN_VER=1
GIT_CNT=$(shell git rev-list --count HEAD)
VER=${MAIN_VER}.${GIT_CNT}

all:
	git push origin master
	sh build.sh ${VER}
