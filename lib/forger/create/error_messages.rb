require "active_support/core_ext/string"

class Forger::Create
  module ErrorMessages
    def handle_ec2_service_error!(exception)
      meth = map_exception_to_method(exception)
      if respond_to?(meth)
        message = send(meth) # custom specific error message
        message = print_error_message(exception, message)
      else
        # generic error message
        print_error_message(exception, <<-EOL)
There was an error with the parameters used for the run_instance method.
EOL
      end
    end

    # Examples:
    #   Aws::EC2::Errors::InvalidGroupNotFound => invalid_group_not_found
    #   Aws::EC2::Errors::InvalidParameterCombination => invalid_parameter_combination
    def map_exception_to_method(exception)
      class_name = File.basename(exception.class.to_s).sub(/.*::/,'')
      class_name.underscore # method_name
    end

    def print_error_message(exception, message)
      puts "ERROR: Unable to launch the instance.".colorize(:red)
      puts message
      puts exception.message
      puts "For the full internal backtrace re-run the command with DEBUG=1"
      puts exception.backtrace if ENV['DEBUG']
      exit 1
    end

    #######################################################
    # specific messages with a little more info for more common error cases below:
    def invalid_group_not_found
      <<-EOL
The security group passed in does not exit.
Please double check that security group exists in the VPC.
EOL
    end

    def invalid_parameter_combination
      <<-EOL
The parameters passed to the run_instances method were invalid.
Please double check that the parameters are all valid.
EOL
    end

    def invalid_subnet_id_not_found
      <<-EOL
The provided subnets ids were were not found.
Please double check that the subnets exists.
EOL
    end
  end
end
