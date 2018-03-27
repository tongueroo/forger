require 'yaml'
require 'active_support/core_ext/hash'

module AwsEc2
  class Create < Base
    autoload :Params, "aws_ec2/create/params"
    autoload :ErrorMessages, "aws_ec2/create/error_messages"

    include AwsService
    include ErrorMessages

    def run
      Profile.new(@options).check!

      Hook.run(:before_run_instances, @options)
      sync_scripts_to_s3

      puts "Creating EC2 instance #{@name.colorize(:green)}"
      display_ec2_info
      if @options[:noop]
        puts "NOOP mode enabled. EC2 instance not created."
        return
      end
      resp = run_instances(params)
      instance_id = resp.instances.first.instance_id
      display_spot_info(instance_id)
      puts "EC2 instance #{@name} created: #{instance_id} 🎉"
      puts "Visit https://console.aws.amazon.com/ec2/home to check on the status"
      display_cloudwatch_info(instance_id)
    end

    def run_instances(params)
      ec2.run_instances(params)
    rescue Aws::EC2::Errors::ServiceError => e
      handle_ec2_service_error!(e)
    end

    # Configured by config/settings.yml.
    # Example: config/settings.yml:
    #
    #   development:
    #     s3_folder: my-bucket/folder
    def sync_scripts_to_s3
      if AwsEc2.settings["s3_folder"]
        Script::Upload.new(@options).run
      end
    end

    # params are main derived from profile files
    def params
      @params ||= Params.new(@options).generate
    end

    def display_spot_info(instance_id)
      resp = ec2.describe_instances(instance_ids: [instance_id])
      spot_id = resp.reservations.first.instances.first.spot_instance_request_id
      return unless spot_id

      puts "Spot instance request id: #{spot_id}"
    end

    def display_ec2_info
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

    def display_cloudwatch_info(instance_id)
      return unless @options[:cloudwatch]

      region = get_region
      url = "https://#{region}.console.aws.amazon.com/cloudwatch/home?region=#{region}#logEventViewer:group=ec2;stream=#{instance_id}/var/log/cloud-init-output.log"
      puts "To view instance's cloudwatch logs visit:"
      puts "  #{url}"
      puts "Note: It takes a little time for the instance to launch and report logs."
      add_to_clipboard(url)
    end

    def add_to_clipboard(text)
      return unless RUBY_PLATFORM =~ /darwin/
      return unless system("type pbcopy > /dev/null")

      system(%[echo "#{text}" | pbcopy])
      puts "Pro tip: The CloudWatch Console Link has been added to your copy-and-paste clipboard."
    end

    def get_region
      # Highest precedence is the setting in ~/.aws/config and AWS_PROFILE used
      aws_found = system("type aws > /dev/null")
      if aws_found
        region = `aws configure get region`.strip
        return region
      end

      # Assumes instace being launched in the same region as the calling ec2 instance
      curl_found = system("type curl > /dev/null")
      if curl_found
        region = `curl --connect-timeout 3  -s 169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/.$//'`
        return region unless region == ''
      end

      return 'us-east-1' # fallback default
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
