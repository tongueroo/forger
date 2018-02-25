module AwsEc2::TemplateHelper::AmiHelper
  include AwsEc2::AwsServices

  # Example:
  #
  #   latest_ami("ruby-2.5.0_*") => ami-122
  #
  # Equivalent aws cli test command:
  #
  #   $ aws ec2 describe-images --owners self --filters="Name=name,Values=ruby-2.5.0_*" | jq '.Images | length'
  #
  # Returns latest ami ami
  def latest_ami(query, owners=["self"])
    images = search_ami(query, owners)
    image = images.sort_by(&:name).reverse.first
    if image
      image.image_id
    else
      puts "latest_ami helper method could not find an AMI with the query of: #{query.inspect}".colorize(:red)
      exit 1
    end
  end

  def search_ami(query, owners=["self"])
    ec2.describe_images(
      owners: owners,
      filters: [
        {name: "name", values: [query]}
      ]
    ).images
  end
end
