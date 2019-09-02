module Forger::Template::Helper::ScriptHelper
  # Bash code that is meant to included in user-data
  def extract_scripts(options={})
    settings_options = settings["extract_scripts"] || {}
    options = settings_options.merge(options)
    # defaults also here in case they are removed from settings
    to = options[:to] || "/opt"
    user = options[:as] || "ec2-user"

    if Dir.glob("#{Forger.root}/app/scripts*").empty?
      puts "WARN: you are using the extract_scripts helper method but you do not have any app/scripts.".color(:yellow)
      calling_line = caller[0].split(':')[0..1].join(':')
      puts "Called from: #{calling_line}"
      return ""
    end

    <<-BASH_CODE
# Generated from the forger extract_scripts helper.
# Downloads scripts from s3, extract them, and setup.
mkdir -p #{to}
aws s3 cp #{scripts_s3_path} #{to}/
(
  cd #{to}
  rm -rf #{to}/scripts # cleanup
  tar zxf #{to}/#{scripts_name}
  chmod -R a+x #{to}/scripts
  chown -R #{user}:#{user} #{to}/scripts
)
BASH_CODE
  end

private
  def register_extract_scripts

  end

  def scripts_name
    File.basename(scripts_s3_path)
  end

  def scripts_s3_path
    upload = Forger::Script::Upload.new
    upload.s3_dest
  end
end
