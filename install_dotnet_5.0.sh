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

if [ -n "$DOTNET_ROOT" ]; then
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

# Environment variables for installation using ARM32 installations
# Date: 2021-06-02
sdk_version="5.0.300"
sdk_filename="dotnet-sdk-5.0.300-linux-arm.tar.gz"
sdk_direct_link="https://download.visualstudio.microsoft.com/download/pr/4bbb3a8d-e32a-4822-81d8-b2c570414f0a/aa7659eac0f0c52316a0fa7aa7c2081a/dotnet-sdk-5.0.300-linux-arm.tar.gz"
sdk_checksum="9e507eac7d6598188766d6281ee8102c8f2b738611a4050cc7cbce7723591dce4b6e8d35588561741852f46a6f9af4fd4b715c328007a461cc5fb468d7ab0d8c"

asp_version="5.0.6"
asp_filename="aspnetcore-runtime-5.0.6-linux-arm.tar.gz"
asp_direct_link="https://download.visualstudio.microsoft.com/download/pr/9d2abf34-b484-46ab-8e3b-504b0057827b/7266d743d6441c1f80510a50c17491dc/aspnetcore-runtime-5.0.6-linux-arm.tar.gz"
asp_checksum="d00b6198ace6aa2b9b164297be42cd442099fd128d3409e17d20d3d1a67d2ab9e2350d3ceea7260101b60247402d828be09b714cd431e7211fd9dee49fba35c7"

echo Installing .NET at $install_dir
echo Installing .NET 5.0 sdk: $sdk_version aspnetcore-runtime: $asp_version

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
if [ -d "$install_dir" ]; then
    echo Folder $install_dir exists
else
    echo Creating folder $install_dir
    mkdir $install_dir
fi

echo Unzipping $sdk_filename
tar zxf $sdk_filename -C $install_dir
echo Unzipping $asp_filename
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
