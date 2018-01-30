#!/bin/bash -exu

exec > >(tee "/var/log/user-data.log" | logger -t user-data -s 2>/dev/console) 2>&1
export HOME=/root # user-data env runs in weird shell where user is root but HOME is not set
<% pubkey_path = "#{ENV['HOME']}/.ssh/id_rsa.pub" -%>
<% if File.exist?(pubkey_path) -%>
<% pubkey = IO.read(pubkey_path).strip -%>
# Automatically add user's public key
echo <%= pubkey %> >> ~/.ssh/authorized_keys
echo <%= pubkey %> >> /home/ec2-user/.ssh/authorized_keys
chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys
<% else %>
# WARN: unable to find a ~/.ssh/id_rsa.pub locally on your machine.  user: <%= ENV['USER'] %>
# Unable to automatically add the public key
<% end -%>

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
