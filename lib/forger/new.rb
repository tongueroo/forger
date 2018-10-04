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
        [:vpc_id, desc: "Vpc id. For config/development.yml network settings."],
        [:s3_folder, desc: "s3_folder setting for config/settings.yml."],
      ]
    end

    cli_options.each do |args|
      class_option *args
    end
    
    def configure_network_settings
      return if ENV['TEST']

      nework = Network.new(@options[:vpc_id])
      @default_subnet = nework.subnet_ids.first
      @default_security_group = nework.security_group_id
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
  forger create my-box --noop # dry-run
EOL
    end
  end
end
