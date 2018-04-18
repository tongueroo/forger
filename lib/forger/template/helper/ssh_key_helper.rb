module Forger::Template::Helper::SshKeyHelper
  def add_ssh_key(user="ec2-user")
    key_path = "#{ENV['HOME']}/.ssh/id_rsa.pub"
    if File.exist?(key_path)
      public_key = IO.read(key_path).strip
    end
    if public_key
      <<-SCRIPT
# Automatically add user's public key from #{key_path}
cp /home/#{user}/.ssh/authorized_keys{,.bak}
echo #{public_key} >> /home/#{user}/.ssh/authorized_keys
chown #{user}:#{user} /home/#{user}/.ssh/authorized_keys
SCRIPT
    else
      <<-SCRIPT
# WARN: unable to find a ~/.ssh/id_rsa.pub locally on your machine.  user: #{ENV['USER']}
# Unable to automatically add the public key
SCRIPT
    end
  end
end
