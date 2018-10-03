#!/bin/bash -exu

export HOME=/root # user-data env runs in weird shell where user is root but HOME is not set

sudo yum install -y postgresql

# https://gist.github.com/juno/1330165
# Install developer tools
yum install -y git gcc make readline-devel openssl-devel

# Install ruby-build system-widely
git clone git://github.com/sstephenson/ruby-build.git /tmp/ruby-build
cd /tmp/ruby-build
./install.sh
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc

# Install rbenv for root
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
set +u
source ~/.bashrc
set -u

# Install and enable ruby
rbenv install 2.5.0

# Install ruby for ec2-user also
cp -R ~/.rbenv /home/ec2-user/
chown -R ec2-user:ec2-user /home/ec2-user/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/ec2-user/.bashrc
echo 'eval "$(rbenv init -)"' >> /home/ec2-user/.bashrc
echo '2.5.0' > /home/ec2-user/.ruby-version

uptime | tee /var/log/boot-time.log
