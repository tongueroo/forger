module Forger::Cleaner
  class Ami < Forger::Base
    include Forger::AwsService

    def clean
      query = @options[:query]
      keep = @options[:keep] || 2
      puts "Cleaning out old AMIs with base name: #{@options[:query]}"
      return if ENV['TEST']

      images = search_ami(query)
      images = images.sort_by { |i| i.name }.reverse
      delete_list = images[keep..-1] || []
      puts "Deleting #{delete_list.size} images."
      delete_list.each do |i|
        delete(i)
      end
    end

  private
    def delete(image)
      message = "Deleting image: #{image.image_id} #{image.name}"
      if @options[:noop]
        puts "NOOP: #{message}"
      else
        puts message
        ec2.deregister_image(image_id: image.image_id)
      end
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
