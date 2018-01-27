module AwsEc2::TemplateHelper::AmiHelper
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
    images = ec2.describe_images(
      owners: owners,
      filters: [
        {name: "name", values: [query]}
      ]
    ).images
    image = images.sort_by(&:name).reverse.first
    image.image_id
  end
end
