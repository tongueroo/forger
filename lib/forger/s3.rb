module Forger
  class S3 < Command
    desc "deploy", "deploys forger managed s3 bucket"
    long_desc Help.text("s3/deploy")
    def deploy
      Bucket.new(options).deploy
    end

    desc "show", "shows forger managed s3 bucket"
    long_desc Help.text("s3/show")
    option :sure, type: :boolean, desc: "Bypass are you sure prompt"
    def show
      Bucket.new(options).show
    end

    desc "delete", "deletes forger managed s3 bucket"
    long_desc Help.text("s3/delete")
    option :sure, type: :boolean, desc: "Bypass are you sure prompt"
    def delete
      Bucket.new(options).delete
    end
  end
end
