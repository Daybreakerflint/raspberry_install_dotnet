#!/bin/bash
# Copyright (c) 2020 Adrian Dummermuth 'Daybreakerflint'
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

user=$(whoami)

install_dir="/usr/share/dotnet"
if [[ ( $user != "root" ) ]]; then
    install_dir="/home/$user/dotnet"
fi

if [ -n ${DOTNET_ROOT} ]; then
    # DOTNET_ROOT is set
    echo Previous installation detected
    if [[ ( $user != "root" ) && ( $DOTNET_ROOT != $install_dir ) ]]; then
        echo Run script as root!
        exit 1;
    else
        # We are root anyway, we can install it anywhere
        install_dir=$DOTENT_ROOT
    fi
fi

echo Installing .NET at $install_dir
echo Installing .NET 5.0 sdk: 5.0.101 aspnetcore-runtime: 5.0.1

# Environment variables for installation
# Version: 5.0.1 
# Date: 2020-12-08
sdk_filename="dotnet-sdk-5.0.101-linux-arm.tar.gz"
sdk_direct_link="https://download.visualstudio.microsoft.com/download/pr/567a64a8-810b-4c3f-85e3-bc9f9e06311b/02664afe4f3992a4d558ed066d906745/dotnet-sdk-5.0.101-linux-arm.tar.gz"
sdk_checksum="2b03ae553b59ad39aa22b5abb5b208318b15284889a86abdc3096e382853c28b0438e2922037f9bc974c85991320175ba48d7a6963bb112651d7027692bb5cde"
asp_filename="aspnetcore-runtime-5.0.1-linux-arm.tar.gz"
asp_direct_link="https://download.visualstudio.microsoft.com/download/pr/11977d43-d937-4fdb-a1fb-a20d56f1877d/73aa09b745586ac657110fd8b11c0275/aspnetcore-runtime-5.0.1-linux-arm.tar.gz"
asp_checksum="a7aa5431d79b69279a1ee9b39503030247001b747ccdd23411ff77b4f88458a49c198de35d1c1fa452684148ad9e1a176c27da97c8ff03df9ee5c3c10909c8b5"

wget $sdk_direct_link
wget $asp_direct_link
sdk_shasum=$(sha512sum $sdk_filename)
asp_shasum=$(sha512sum $asp_filename)
if [[ ($sdk_shasum != *$sdk_checksum*) || ($asp_shasum != *$asp_checksum*) ]]; then
    echo Failed! Abort!
    exit 1
fi
echo Files are correct!

echo -----------------------
echo Unzipping files to $install_dir
mkdir $install_dir
tar zxf $sdk_filename -C $install_dir
tar zxf $asp_filename -C $install_dir
rm -rf $sdk_filename
rm -rf $asp_filename

if command -v dotnet &> /dev/null
then
    echo Everything already setup!
    echo Check settings of .bashrc or /etc/bash.bash.bashrc and links
    exit 0
fi

if [[ ( $user != "root" ) ]]; then
    echo '# Export environment variables for dotnet' >> /home/$user/.bashrc
    echo 'export DOTNET_ROOT='$install_dir >> /home/$user/.bashrc
    echo 'export PATH=$PATH:'$install_dir >> /home/$user/.bashrc
    echo 'export PATH=$PATH:/home/'$user'/.dotnet/tools' >> /home/$user/.bashrc
    echo -----------------------
    echo Adding symbolic links /usr/share/dotnet and /usr/bin/dotnet --> requires root access
    sudo ln -s $install_dir/ /usr/share/dotnet
    sudo ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
else
    echo '# Export environment variables for dotnet' >> /etc/bash.bashrc
    echo 'export DOTNET_ROOT='$install_dir >> /etc/bash.bashrc
    echo 'export PATH=$PATH:'$install_dir  >> /etc/bash.bashrc
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
    echo 'Check if this line is in your .bashrc:'
    echo 'export PATH=$PATH:/home/{user}/.dotnet/tools'
fi

exit 0
