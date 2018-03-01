require "base64"
require "erb"
require "byebug" if ENV['USER'] == 'tung'

module AwsEc2::Template::Helper::CoreHelper
  def user_data(name, base64:true, layout:"default")
    # allow user to specify the path also
    if File.exist?(name)
      name = File.basename(name) # normalize name, change path to name
    end
    name = File.basename(name, '.sh')

    layout_path = layout_path(layout)
    path = "#{AwsEc2.root}/app/user-data/#{name}.sh"
    result = RenderMePretty.result(path, context: self, layout: layout_path)
    result = append_scripts(result)

    # save the unencoded user-data script for easy debugging
    temp_path = "#{AwsEc2.root}/tmp/user-data.txt"
    FileUtils.mkdir_p(File.dirname(temp_path))
    IO.write(temp_path, result)

    base64 ? Base64.encode64(result).strip : result
  end

  # Get full path of layout from layout name
  #
  #   layout_name=false - dont use layout at all
  #   layout_name=nil - default to default.sh layout if available
  def layout_path(name="default")
    return false if name == false # disable layout
    name = "default" if name.nil? # in case user passes in nil

    ext = File.extname(name)
    name += ".sh" if ext.empty?
    layout_path = "#{AwsEc2.root}/app/user-data/layouts/#{name}"

    # special rule for default in case there's no default layout
    if name.include?("default") and !File.exist?(layout_path)
      return false
    end

    # other named layouts should error if it doesnt exit
    unless File.exist?(layout_path)
      puts "ERROR: Layout #{layout_path} does not exist. Are you sure it exists?  Exiting".colorize(:red)
      exit 1
    end

    layout_path
  end

  # provides access to config/* settings as variables
  #   AWS_EC2_ENV=development => config/development.yml
  #   AWS_EC2_ENV=production => config/production.yml
  def config
    AwsEc2.config
  end

  # provides access to config/settings.yml as variables
  def settings
    AwsEc2.settings
  end

  # pretty timestamp that is useful for ami ids.
  # the timestamp is generated once and cached.
  def timestamp
    @timestamp ||= Time.now.strftime("%Y-%m-%d-%H-%M-%S")
  end

private
  def append_scripts(user_data)
    # assuming user-data script is a bash script for simplicity for now
    script = AwsEc2::Script.new(@options)
    requires_setup = @options[:auto_terminate] || @options[:ami_name]
    user_data += script.setup_scripts if requires_setup
    user_data += script.auto_terminate if @options[:auto_terminate]
    user_data += script.create_ami if @options[:ami_name]
    user_data
  end

  # Load custom helper methods from the project repo
  def load_custom_helpers
    Dir.glob("#{AwsEc2.root}/app/helpers/**/*_helper.rb").each do |path|
      filename = path.sub(%r{.*/},'').sub('.rb','')
      module_name = filename.classify

      require path
      self.class.send :include, module_name.constantize
    end
  end
end
