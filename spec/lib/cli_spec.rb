require "spec_helper"

# to run specs with what"s remembered from vcr
#   $ rake
#
# to run specs with new fresh data from aws api calls
#   $ rake clean:vcr ; time rake
describe AwsEc2::CLI do
  before(:all) do
    @args = "--noop"
  end

  describe "aws-ec2" do
    it "create" do
      out = execute("exe/aws-ec2 create server #{@args}")
      expect(out).to include("Creating EC2 instance server")
    end
  end
end
