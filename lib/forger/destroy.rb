module Forger
  class Destroy < Base
    include AwsServices

    def run(instance_id)
      puts "Destroying #{instance_id}"
      return if ENV['TEST']

      cancel_spot_request(instance_id)
      ec2.terminate_instances(instance_ids: [instance_id])
      puts "Instance #{instance_id} terminated."
    end

    def cancel_spot_request(instance_id)
      resp = ec2.describe_instances(instance_ids: [instance_id])
      spot_id = resp.reservations.first.instances.first.spot_instance_request_id

      return unless spot_id
      ec2.cancel_spot_instance_requests(spot_instance_request_ids: [spot_id])
      puts "Spot instance request #{spot_id} cancelled."
    end
  end
end
