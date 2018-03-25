module AwsEc2::Cleaner
  class Ami < AwsEc2::Base
    include AwsEc2::AwsService

    def clean
      query = @options[:query] + "*" # use query as base of name for search
      keep = @options[:keep] || 2
      puts "Cleaning out old AMIs with base name: #{@options[:query]}"
      return if ENV['TEST']

      images = search_ami(query)
      images.sort_by! { |i| i.name }.reverse
      delete_list = images[keep..-1] || []
      puts "Deleting #{delete_list.size} images."
      delete_list.each do |i|
        puts "Deleting image: #{i.image_id} #{i.name}"
        delete(i.image_id)
      end
    end

  private
    def delete(image_id)
      ec2.deregister_image(image_id: image_id)
    rescue Aws::EC2::Errors::InvalidAMIIDUnavailable
      # happens when image was just deleted but its still
      # showing up as available when calling describe_images
      puts "WARN: #{e.message}"
    end

    def search_ami(query, owners=["self"])
      ec2.describe_images(
        owners: owners,
        filters: [
          {name: "name", values: [query]},
          {name: "state", values: ["available"]}
        ]
      ).images
    end
  end
end
