require "base64"
require "erb"

module Forger::Template::Helper::CoreHelper
  # assuming user-data script is a bash script for simplicity for now
  def user_data(name, base64:true, layout:"default")
    name = normalize_user_data_name_input(name)
    layout_path = layout_path(layout)

    path = "#{Forger.root}/app/user_data/#{name}"
    unless File.exist?(path)
      puts "ERROR: user-data script #{path.color(:red)} does not exist"
      exit 1
    end
    result = RenderMePretty.result(path, context: self, layout: layout_path)
    # Must prepend and append scripts in user_data here because we need to
    # encode the user_data script for valid yaml to load in the profile.
    # Tried moving this logic to the params but that is too late and produces
    # invalid yaml.  Unless we want to encode and dedode twice.
    scripts = [result]
    scripts = prepend_scripts(scripts)
    scripts = append_scripts(scripts)
    divider = "\n############################## DIVIDER ##############################\n"
    result = scripts.join(divider)

    # save the unencoded user-data script for easy debugging
    temp_path = "#{Forger.build_root}/user-data.txt"
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
    layout_path = "#{Forger.root}/app/user_data/layouts/#{name}"

    # special rule for default in case there's no default layout
    if name.include?("default") and !File.exist?(layout_path)
      return false
    end

    # other named layouts should error if it doesnt exit
    unless File.exist?(layout_path)
      puts "ERROR: Layout #{layout_path} does not exist. Are you sure it exists?  Exiting".color(:red)
      exit 1
    end

    layout_path
  end

  # provides access to config/* settings as variables
  #   FORGER_ENV=development => config/variables/development.rb
  #   FORGER_ENV=production  => config/variables/production.rb
  def vars
    Forger.vars
  end
  alias_method :variables, :vars

  # provides access to config/settings.yml as variables
  def settings
    Forger.settings
  end

  # pretty timestamp that is useful for ami ids.
  # the timestamp is generated once and cached.
  def timestamp
    @timestamp ||= Time.now.strftime("%Y-%m-%d-%H-%M-%S")
  end

private
  def cloudwatch_enabled?
    Forger.cloudwatch_enabled?(@options)
  end

  # TODO: move script combining logic into class
  def prepend_scripts(scripts)
    scripts.unshift(script.cloudwatch) if cloudwatch_enabled?
    scripts.unshift(script.auto_terminate_after_timeout) if @options[:auto_terminate]
    add_setup_script(scripts, :prepend)
    scripts
  end

  def append_scripts(scripts)
    add_setup_script(scripts, :append)
    scripts << script.auto_terminate if @options[:auto_terminate]
    scripts << script.create_ami if @options[:ami_name]
    scripts
  end

  def add_setup_script(scripts, how)
    return if @already_setup
    @already_setup = true

    requires_setup = cloudwatch_enabled? ||
                     @options[:auto_terminate] ||
                     @options[:ami_name]

    return unless requires_setup

    if how == :prepend
      scripts.unshift(script.extract_forger_scripts)
    else
      scripts << script.extract_forger_scripts
    end

    scripts
  end

  def script
    @script ||= Forger::Script.new(@options)
  end

  # Load custom helper methods from the project repo
  def load_custom_helpers
    Dir.glob("#{Forger.root}/app/helpers/**/*_helper.rb").each do |path|
      filename = path.sub(%r{.*/},'').sub('.rb','')
      module_name = filename.camelize

      require path
      self.class.send :include, module_name.constantize
    end
  end

private
  def normalize_user_data_name_input(name)
    ext = File.extname(name)
    name += ".sh" if ext.empty?
    name
  end
end
