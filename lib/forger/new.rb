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
      ]
    end

    cli_options.each do |args|
      class_option *args
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

Change into the project directory:

    cd #{project_name}

Inspect and edit these files for your needs:

* config/settings.yml - you probably want to edit aws_profiles and s3_folder.
* config/development.yml - your custom variables available for use in other forger files.
* profiles/default.yml - the parameters that get sent to the aws-sdk run_instances call.

Preview what forger creates:

    forger create my-box --noop # dry-run
    
It is useful to check:

* The s3 upload is uploading to your desired bucket.
* The generated user_data script makes sense. It is in `tmp/user-data.txt`.

Once you're ready, launch the instance:

    forger create my-box --noop # dry-run
EOL
    end
  end
end
