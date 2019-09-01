module Forger
  class New < Sequence
    argument :project_name

    # Ugly, but when the class_option is only defined in the Thor::Group class
    # it doesnt show up with cli-template new help :(
    # If anyone knows how to fix this let me know.
    # Also options from the cli can be pass through to here
    def self.cli_options
      [
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files."],
        [:git, type: :boolean, default: true, desc: "Git initialize the project"],
        [:iam, desc: "iam_instance_profile to use in the profiles/default.yml"],
        [:key_name, desc: "key name to use with launched instance in profiles/default.yml"],
        [:security_group, desc: "Security group to use. For config/variables/development.rb network settings."],
        [:subnet, desc: "Subnet to use. For config/variables/development.rb network settings."],
        [:vpc_id, desc: "Vpc id. For config/variables/development.rb network settings. Will use default sg and subnet"],
      ]
    end

    cli_options.each do |args|
      class_option(*args)
    end

    def configure_network_settings
      return if ENV['TEST']

      network = Network.new(@options[:vpc_id]) # used for default settings
      @subnet = @options[:subnet] || network.subnet_ids.first
      @security_group = @options[:security_group] || network.security_group_id
    end

    def create_project
      copy_project
      destination_root = "#{Dir.pwd}/#{project_name}"
      self.destination_root = destination_root
      FileUtils.cd("#{Dir.pwd}/#{project_name}")
    end

    def make_executable
      chmod("exe", 0755 & ~File.umask, verbose: false) if File.exist?("exe")
    end

    def bundle_install
      Bundler.with_clean_env do
        system("BUNDLE_IGNORE_CONFIG=1 bundle install")
      end
    end

    def git_init
      return if !options[:git]
      return unless git_installed?
      return if File.exist?(".git") # this is a clone repo

      run("git init")
      run("git add .")
      run("git commit -m 'first commit'")
    end

    def user_message
      puts <<-EOL
#{"="*64}
Congrats 🎉 You have successfully generated a starter forger project.

Test the CLI:

  cd #{project_name}
  forger create box --noop # dry-run to see the tmp/user-data.txt script
  forger create box # live-run
  forger create box --ssh
EOL
    end
  end
end
