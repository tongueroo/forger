module AwsEc2::Template::Helper::PartialHelper
  def partial_exist?(path)
    path = partial_path_for(path)
    path = auto_add_format(path)
    path && File.exist?(path)
  end

  # The partial's path is a relative path given without the extension and
  #
  # Example:
  # Given: file in app/partials/mypartial.sh
  # The path should be: mypartial
  #
  # If the user specifies the extension then use that instead of auto-adding
  # the detected format.
  def partial(path,vars={}, options={})
    path = partial_path_for(path)
    path = auto_add_format(path)

    result = RenderMePretty.result(path, context: self)
    result = indent(result, options[:indent]) if options[:indent]
    if options[:indent]
      # Add empty line at beginning because empty lines gets stripped during
      # processing anyway. This allows the user to call partial without having
      # to put the partial call at very beginning of the line.
      # This only should happen if user is using indent option.
      ["\n", result].join("\n")
    else
      result
    end
  end

  # add indentation
  def indent(text, indentation_amount)
    text.split("\n").map do |line|
      " " * indentation_amount + line
    end.join("\n")
  end

private
  def partial_path_for(path)
    "#{AwsEc2.root}/app/partials/#{path}"
  end

  def auto_add_format(path)
    # Return immediately if user provided explicit extension
    extension = File.extname(path) # current extension
    return path if !extension.empty?

    # Else let's auto detect
    paths = Dir.glob("#{path}.*")

    if paths.size == 1 # non-ambiguous match
      return paths.first
    end

    if paths.size > 1 # ambiguous match
      puts "ERROR: Multiple possible partials found:".colorize(:red)
      paths.each do |path|
        puts "  #{path}"
      end
      puts "Please specify an extension in the name to remove the ambiguity.".colorize(:green)
      exit 1
    end

    # Account for case when user wants to include a file with no extension at all
    return path if File.exist?(path) && !File.directory?(path)

    path # original path if this point is reached
  end
end
