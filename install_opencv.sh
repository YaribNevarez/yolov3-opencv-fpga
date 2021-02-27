cvVersion="master"

# Clean build directories
rm -rf opencv/build
rm -rf opencv_contrib/build

# Create directory for installation
mkdir installation
mkdir installation/OpenCV-"$cvVersion"

# Save current working directory
cwd=$(pwd)

sudo apt -y update
sudo apt -y upgrade

######################### Install OS Libraries ####################################
sudo apt -y remove x264 libx264-dev

## Install dependencies
sudo apt -y install build-essential checkinstall cmake pkg-config yasm
sudo apt -y install git gfortran
sudo apt -y install libjpeg8-dev libpng-dev

sudo apt -y install software-properties-common
sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
sudo apt -y update

sudo apt -y install libjasper1
sudo apt -y install libtiff-dev

sudo apt -y install libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev
sudo apt -y install libxine2-dev libv4l-dev
cd /usr/include/linux
sudo ln -s -f ../libv4l1-videodev.h videodev.h
cd "$cwd"

sudo apt -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt -y install libgtk2.0-dev libtbb-dev qt5-default
sudo apt -y install libatlas-base-dev
sudo apt -y install libfaac-dev libmp3lame-dev libtheora-dev
sudo apt -y install libvorbis-dev libxvidcore-dev
sudo apt -y install libopencore-amrnb-dev libopencore-amrwb-dev
sudo apt -y install libavresample-dev
sudo apt -y install x264 v4l-utils

# Optional dependencies
sudo apt -y install libprotobuf-dev protobuf-compiler
sudo apt -y install libgoogle-glog-dev libgflags-dev
sudo apt -y install libgphoto2-dev libeigen3-dev libhdf5-dev doxygen

####################### Install Python Libraries ###########################
sudo apt -y install python3-dev python3-pip
sudo -H pip3 install -U pip numpy
sudo apt -y install python3-testresources


################### Download opencv and opencv_contrib ######################

git clone https://github.com/opencv/opencv.git
cd opencv
git checkout $cvVersion
cd ..

git clone https://github.com/opencv/opencv_contrib.git
cd opencv_contrib
git checkout $cvVersion
cd ..

############### compile #####################################

cd opencv
mkdir build
cd build

##########################################################################################################################################
#### Select compilation flags ############################################################################################################
##########################################################################################################################################

# Tow standrad options:


#### Release
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D WITH_TBB=ON -D WITH_V4L=ON -D OPENCV_PYTHON3_INSTALL_PATH=$cwd/OpenCV-$cvVersion-py3/lib/python3.5/site-packages -D WITH_QT=ON -D WITH_OPENGL=ON -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules -D BUILD_EXAMPLES=ON -D OPENCV_GENERATE_PKGCONFIG=YES ..


#### Debug
# cmake -D BUILD_SHARED_LIBS=OFF -D CMAKE_BUILD_TYPE=DEBUG -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D WITH_TBB=ON -D WITH_V4L=ON -D OPENCV_PYTHON3_INSTALL_PATH=$cwd/OpenCV-$cvVersion-py3/lib/python3.5/site-packages -D WITH_QT=ON -D WITH_OPENGL=ON -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules -D BUILD_EXAMPLES=ON -D OPENCV_GENERATE_PKGCONFIG=YES -D ENABLE_PROFILING=ON ..



#### More options:

#### 1. I don’t care about anything and just want the examples to work.
#### You’re going to want the BUILD_EXAMPLES flag on.
# cmake -D CMAKE_BUILD_TYPE=RELEASE -D BUILD_EXAMPLES=ON -D CMAKE_INSTALL_PREFIX=/usr/local ..


#### 2. I wish my build went a little faster, and just want the examples and apps to work.
#### You’re going to turn off docs, tests, etc, but keep examples on.
# cmake -D CMAKE_BUILD_TYPE=RELEASE -D BUILD_EXAMPLES=ON  -D BUILD_DOCS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D CMAKE_INSTALL_PREFIX=/usr/local ..


#### 3. I want my compile to be fast and my code to be speedy
#### You’re going to turn on ALL the optimization flags, in case your system supports multiple of them, and turn off all the performance/test checks.
#### (note: This is a naive ‘turn on all the multi-threading!!’ solution, because different parts of OpenCV allow for different kinds of performance speedups - some apps can be OpenMP’d with really simple changes, others use TBB or IPP natively, so it is kind of a jumble #opensource. Hence, the turn on everything approach.)
# cmake -D WITH_TBB=ON -D WITH_OPENMP=ON -D WITH_IPP=ON -D CMAKE_BUILD_TYPE=RELEASE -D BUILD_EXAMPLES=OFF -D WITH_NVCUVID=ON -D WITH_CUDA=ON -D BUILD_DOCS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D WITH_CSTRIPES=ON -D WITH_OPENCL=ON CMAKE_INSTALL_PREFIX=/usr/local/ ..


#### 4. I want to debug my (MULTITHREADED) code, including library calls.
#### You’re going to compile statically and enable -g -pg compile flags.
# cmake [YOUR FAVORITE OPTIMIZATIONS FROM ITEM 3 HERE] -D ENABLE_PROFILING=ON -D CMAKE_BUILD_TYPE=Debug -D BUILD_SHARED_LIBS=OFF -D CMAKE_INSTALL_PREFIX=/usr/local/ ..


#### 5. I want to debug my (SINGLETHREADED) code, including library calls.
#### This is like 3+4, but with all the multithreading flags turned off.
# cmake -D WITH_TBB=OFF -D WITH_OPENMP=OFF -D WITH_IPP=OFF -D ENABLE_PROFILING=ON -D CMAKE_BUILD_TYPE=Debug -D BUILD_EXAMPLES=OFF -D WITH_NVCUVID=OFF -D WITH_CUDA=OFF -D BUILD_DOCS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D WITH_CSTRIPES=OFF -D WITH_OPENCL=OFF CMAKE_INSTALL_PREFIX=/usr/local/ ..


#### 6. I don’t care about anything and don’t want to compile the apps or examples.
#### Turns off all the apps and stuff, compiles normally.
# cmake -D BUILD_EXAMPLES=OFF -D BUILD_opencv_apps=OFF -D BUILD_DOCS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D CMAKE_INSTALL_PREFIX=/usr/local/ ..


##########################################################################################################################################
##########################################################################################################################################
##########################################################################################################################################

make -j4
make install
# make install
sudo ldconfig


echo 'export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig/opencv4.pc' >> ~/.bashrc

########## Copile command:
# g++ `pkg-config opencv4 --cflags` program.cpp -o program.out `pkg-config opencv4 --libs`