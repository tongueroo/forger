require 'yaml'
require 'active_support/core_ext/hash'

module AwsEc2
  class Create < Base
    autoload :Params, "aws_ec2/create/params"
    autoload :ErrorMessages, "aws_ec2/create/error_messages"

    include AwsServices
    include ErrorMessages

    def run
      Profile.new(@options).check!

      puts "Creating EC2 instance #{@name}..."
      display_info
      if @options[:noop]
        puts "NOOP mode enabled. EC2 instance not created."
        return
      end

      Hook.run(:before_run_instances, @options)
      sync_scripts_to_s3
      run_instances(params)
      puts "EC2 instance #{@name} created! 🎉"
      puts "Visit https://console.aws.amazon.com/ec2/home to check on the status"
    end

    def run_instances(params)
      ec2.run_instances(params)
    rescue Aws::EC2::Errors::ServiceError => e
      handle_ec2_service_error!(e)
    end

    # Configured by config/[AWS_EC2_ENV].yml.
    # Example: config/development.yml:
    #
    #   scripts_s3_bucket: my-bucket
    def sync_scripts_to_s3
      if AwsEc2.config["scripts_s3_bucket"]
        Script::Upload.new(@options).upload
      end
    end

    # params are main derived from profile files
    def params
      @params ||= Params.new(@options).generate
    end

    def display_info
      puts "Using the following parameters:"
      pretty_display(params)

      display_launch_template
    end

    def display_launch_template
      launch_template = params[:launch_template]
      return unless launch_template

      resp = ec2.describe_launch_template_versions(
        launch_template_id: launch_template[:launch_template_id],
        launch_template_name: launch_template[:launch_template_name],
      )
      versions = resp.launch_template_versions
      launch_template_data = {} # combined launch_template_data
      versions.sort_by { |v| v[:version_number] }.each do |v|
        launch_template_data.merge!(v[:launch_template_data])
      end
      puts "launch template data (versions combined):"
      pretty_display(launch_template_data)
    rescue Aws::EC2::Errors::InvalidLaunchTemplateNameNotFoundException => e
      puts "ERROR: The specified launched template #{launch_template.inspect} was not found."
      puts "Please double check that it exists."
      exit
    end

    def pretty_display(data)
      data = data.deep_stringify_keys

      if data["user_data"]
        message = "base64-encoded: cat tmp/user-data.txt to view"
        data["user_data"] = message
      end

      puts YAML.dump(data)
    end
  end
end
