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

echo Installing .NET at $install_dir
echo Installing .NET 3.1 sdk: 3.1.404 aspnetcore-runtime: 3.1.10

# Environment variables for installation
# Version: 3.1.10 
# Date: 2020-11-10
sdk_filename="dotnet-sdk-3.1.404-linux-arm.tar.gz"
sdk_direct_link="https://download.visualstudio.microsoft.com/download/pr/2ebe1f4b-4423-4694-8f5b-57f22a315d66/4bceeffda88fc6f19fad7dfb2cd30487/dotnet-sdk-3.1.404-linux-arm.tar.gz"
sdk_checksum="0aaed20c96c97fd51b8e0f525caf75ab95c5a51de561e76dc89dad5d3c18755c0c773b51be6f1f5b07dda02d2bb426c5b9c45bb5dd59914beb90199f41e5c59e"
asp_filename="aspnetcore-runtime-3.1.10-linux-arm.tar.gz"
asp_direct_link="https://download.visualstudio.microsoft.com/download/pr/a2223d1f-c138-4586-8cd1-274c5387e975/623ece755546aca8f4be268f525683c5/aspnetcore-runtime-3.1.10-linux-arm.tar.gz"
asp_checksum="02e304af66734fa14042e59b0c47a1c19ffcacef6dd58f293352dd32a79b5abce303010101384fe25d20cb6391df4bdffc8e3cf766f88781a8e3b1f6b1e2ee0d"

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
