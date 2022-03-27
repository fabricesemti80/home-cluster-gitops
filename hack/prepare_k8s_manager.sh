#!/bin/bash

# colorisation - ref: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
GREEN='\e[32m'
BLUE='e[34m'
RED='e[31m'
NC='\033[0m' # No Color

# ensure we are updated
printf "%60s" " " | tr ' ' '-'
echo -e "${GREEN} Starting system update ${NC}"
sudo apt-get update -y
sleep 3

# ensure we are upgraded
printf "%60s" " " | tr ' ' '-'
echo -e "${GREEN} Starting system update ${NC}"
sudo apt-get upgrade -y
sleep 3

# ensure we have project folder
printf "%60s" " " | tr ' ' '-'
echo -e "${GREEN} Creating [projects] folder ${NC}"
mkdir -p ~/projects
sleep 3

printf "%60s" " " | tr ' ' '-'
echo -e "${GREEN} Installing Git ${NC}"
sudo apt-get install git -y
sleep 3

# install brew
printf "%60s" " " | tr ' ' '-'
echo -e "${GREEN} Installing brew ${NC}"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/fabrice/.profile
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/fabrice/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo apt-get install build-essential -y
brew install gcc
source ~/.bashrc
sleep 3

printf "%60s" " " | tr ' ' '-'
echo -e "${GREEN} Install SOPS ${NC}"
brew install sops
sleep 3

printf "%60s" " " | tr ' ' '-'
echo -e "${GREEN} Install AGE ${NC}"
brew install age
sleep 3

# next:
# - set up ssh
# - checkout repo
# - create sops key
# - add sops key to profile
# - test
