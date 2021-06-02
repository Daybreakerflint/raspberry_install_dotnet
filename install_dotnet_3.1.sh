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
sdk_version="3.1.409"
sdk_filename="dotnet-sdk-3.1.409-linux-arm.tar.gz"
sdk_direct_link="https://download.visualstudio.microsoft.com/download/pr/58d0ebb7-c06d-4d9a-a69f-22dac06fb278/0ae7881b7007c13a8e325d54a8f87657/dotnet-sdk-3.1.409-linux-arm.tar.gz"
sdk_checksum="4908a84951a93acac80c6e7d2dff88b40b90fa079bfc0a02678a70c412a45f1146a3d344c218791edef4bb972d549accadcbfcdc721be0478b07db3a3336cf6d"

asp_version="3.1.15"
asp_filename="aspnetcore-runtime-3.1.15-linux-arm.tar.gz"
asp_direct_link="https://download.visualstudio.microsoft.com/download/pr/000183b9-3d77-4e03-902e-7debe460497d/dcd6400fe1f28baba8624d3242f820a7/aspnetcore-runtime-3.1.15-linux-arm.tar.gz"
asp_checksum="3c4fcbf9eab630f25605cfcbe8c55af452d4b10cc054257e26dfa4bdb09fd025c35cc9ea12dbcbc7c420946e618b9e8ba50ca81525b5055c79323bb7e94b5544"

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
