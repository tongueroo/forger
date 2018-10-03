module ApplicationHelper
  # The domain that the TLS cert for docker will use.
  # The certs are stored on s3 bucket configured in config/development.yml
  #
  # Example:
  #   bob.example.com
  # would:
  #   aws s3 ls s3://infrastructure-dev/docker/tls/
  #   aws s3 ls s3://infrastructure-prod/docker/tls/
  #
  def generate_docker_domain
    "#{ENV['USER']}.#{config["hosted_zone_domain"]}"
  end

  def personalize_script
    path = File.expand_path("../../scripts/personalize/#{ENV['USER']}.sh", __FILE__)
    if File.exist?(path)
      script =<<EOL
#######################################
# personalize script added by ApplicationHelper#personalize_script for #{ENV['USER']}
/opt/scripts/personalize/tung.sh
EOL
    end
  end
end
