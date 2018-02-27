require 'fileutils'

class AwsEc2::Script
  class Compress < AwsEc2::Base
    def compress
      reset
      puts "Tarballing #{BUILD_ROOT}/app/scripts folder to scripts.tgz".colorize(:green)
      tarball_path = create_tarball
      save_scripts_info(tarball_path)
      puts "Tarball created at #{tarball_path}"
    end

    def create_tarball
      # https://apple.stackexchange.com/questions/14980/why-are-dot-underscore-files-created-and-how-can-i-avoid-them
      sh "cd #{BUILD_ROOT}/app && dot_clean ." if system("type dot_clean > /dev/null")

      # https://serverfault.com/questions/110208/different-md5sums-for-same-tar-contents
      # Using tar czf directly results in a new m5sum each time because the gzip
      # timestamp is included.  So using:  tar -c ... | gzip -n
      sh "cd #{BUILD_ROOT}/app && tar -c scripts | gzip -n > scripts.tgz" # temporary app/scripts.tgz file

      rename_with_md5!
    end

    def clean
      FileUtils.rm_f("#{BUILD_ROOT}/scripts/scripts-#{md5sum}.tgz")
    end

    # Apppend a md5 to file after it's been created and moves it to
    # output/scripts/scripts-[MD5].tgz
    def rename_with_md5!
      md5_path = "#{BUILD_ROOT}/scripts/scripts-#{md5sum}.tgz"
      FileUtils.mkdir_p(File.dirname(md5_path))
      FileUtils.mv("#{BUILD_ROOT}/app/scripts.tgz", md5_path)
      md5_path
    end

    def save_scripts_info(scripts_name)
      FileUtils.mkdir_p(File.dirname(SCRIPTS_INFO_PATH))
      IO.write(SCRIPTS_INFO_PATH, scripts_name)
    end

    # cache this because the file will get removed
    def md5sum
      @md5sum ||= Digest::MD5.file("#{BUILD_ROOT}/app/scripts.tgz").to_s[0..7]
    end

    def sh(command)
      puts "=> #{command}"
      system command
    end

    # Only avaialble after script has been built.
    def scripts_name
      IO.read(SCRIPTS_INFO_PATH).strip
    end

    def reset
      FileUtils.rm_f(SCRIPTS_INFO_PATH)
    end
  end
end
