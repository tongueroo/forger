require 'yaml'
require 'active_support/core_ext/hash'

module Forger
  class Create < Base
    include AwsServices
    include ErrorMessages

    def run
      Profile.new(@options).check!

      Hook.run(:before_run_instances, @options)
      sync_scripts_to_s3

      puts "Creating EC2 instance #{@name.color(:green)}"
      info = Info.new(@options, params)
      info.ec2_params
      if @options[:noop]
        puts "NOOP mode enabled. EC2 instance not created."
        return
      end
      resp = run_instances(params)

      instance_id = resp.instances.first.instance_id
      info.spot(instance_id)
      puts "EC2 instance with profile #{@name.color(:green)} created: #{instance_id} 🎉"
      puts "Visit https://console.aws.amazon.com/ec2/home to check on the status"
      info.cloudwatch(instance_id)

      Waiter.new(@options.merge(instance_id: instance_id)).wait
    end

    def run_instances(params)
      ec2.run_instances(params)
    rescue Aws::EC2::Errors::ServiceError => e
      handle_ec2_service_error!(e)
    end

    def sync_scripts_to_s3
      upload = Script::Upload.new(@options)
      return if upload.empty?
      upload.run
    end

    # params are main derived from profile files
    def params
      @params ||= Params.new(@options).generate
    end
  end
end
