#! /bin/bash

# This script will initialize an Ubuntu 16.04 system (containing an Nvidia GPU) to
# be setup for Harvey Mudd College CS 152 course (Neural Networks).

# Much of the script is based on https://github.com/howkhang/fastai-v2-setup/blob/master/setup.sh

# 9/18/18
# Neil Rhodes
# rhodes@hmc.edu

# Make the scripts non-interactive (don't ask questions)
DEBIAN_FRONTEND=noninteractive

echo "Starting install at `date`"

# Unclear why this is needed:)
sudo apt -y install qtdeclarative5-dev qml-module-qtquick-controls
sudo add-apt-repository ppa:graphics-drivers/ppa -y
sudo apt update

# Put downloads in their own directory
mkdir -p ~/downloads
pushd ~/downloads/

# Install Cuda
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
sudo apt update
sudo apt install cuda -y

# Cudnn not donwnloaded from nvidia (no direct download available, must go through license
# agreement to download). fastai hosts these files.
wget http://files.fast.ai/files/cudnn-9.1-linux-x64-v7.tgz
tar xf cudnn-9.1-linux-x64-v7.tgz
sudo cp cuda/include/*.* /usr/local/cuda/include/
sudo cp cuda/lib64/*.* /usr/local/cuda/lib64/

# Could we get by without some of these?  Maybe.
sudo apt-get update && sudo apt-get install -y --allow-downgrades --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         vim \
         ca-certificates \
         python-qt4 \
         libjpeg-dev \
         zip \
         unzip \
         libpng-dev &&\
     sudo rm -rf /var/lib/apt/lists/*


# Install Miniconda

pushd downloads
# Install Miniconda so we don't have issue between jupyter installed
# at top-leel and also within an environment (causes problems with
# ipywidgets.
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
# -b flag means quiet/unattended.  Won't ask questions, won't write to .bashrc
bash Miniconda3-latest-Linux-x86_64.sh -b
echo 'export PATH=~/miniconda3/bin:$PATH' >> ~/.bashrc
export PATH="~/miniconda3/bin:$PATH"
popd

# Create our Conda environment named cs152.  That's where we'll install all
# our stuff.
conda create --name cs152 -y python=3.6

# Make activation automatic on login
echo 'source activate cs152' >> ~/.bashrc
# Activate now
source activate cs152

# Install ipywidgets using conda.  That'll automatically enable the extensions.
conda install -c conda-forge ipywidgets -y

# Install a particular version of fastai (dated around 9/15/18). We do this so all
# students are running the same version and so we don't get an accidental fatal 
# commit (as happend on 9/16/18).
pip install --user git+git://github.com/fastai/fastai.git@cb121994872fbd5f4ee67de01bcb9848a7e54a6b


# Install Kaggle command-line interface
pip install kaggle

# Setup Jupyter config so that it is listening not just on local network
# but also on external network.  Otherwise, we can't reach it via its IP address.
mkdir -p ~/.jupyter
cat >  ~/.jupyter/jupyter_notebook_config.py << HERE_DOC
c = get_config()
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
HERE_DOC


conda install -c conda-forge jupyterlab -y

# Clone our github repository.
if [[ ! -d cs152 ]]; then
cd ..
  git clone https://github.com/nrhodes/cs152.git
fi

# Download the dogs/cats data. We don't download from Kaggle because this
# form of the data has been massaged (broken into train/valid, separated dogs/cats into
# different directories).
if [[ ! -d data ]]; then
  mkdir data
fi
pushd data
if [[ ! -d dogscats ]]; then
  curl http://files.fast.ai/data/dogscats.zip --output dogscats.zip
  unzip -qq dogscats.zip
  rm dogscats.zip
fi
popd

echo "Finished install at `date`"

