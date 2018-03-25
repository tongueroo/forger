describe AwsEc2::CLI do
  before(:all) do
    @args = "--noop"
  end

  describe "aws-ec2" do
    it "create" do
      out = execute("exe/aws-ec2 create server #{@args}")
      expect(out).to include("Creating EC2 instance")
    end

    it "ami" do
      out = execute("exe/aws-ec2 ami myimage #{@args}")
      expect(out).to include("Creating EC2 instance")
    end

    it "wait ami" do
      out = execute("exe/aws-ec2 wait ami myimage")
      expect(out).to include("Waiting for")
    end

    it "clean ami" do
      out = execute("exe/aws-ec2 clean ami imagebasename")
      expect(out).to include("Cleaning out old AMIs")
    end

    commands = {
      "am" => "ami",
      "compile" => "--profile",
      "create -" =>  "--profile",
      "create" => "name",
      "create name --" => "--profile",
    }
    commands.each do |command, expected_word|
      it "completion #{command}" do
        out = execute("exe/aws-ec2 completion #{command}")
        expect(out).to include(expected_word) # only checking for one word for simplicity
      end
    end
  end
end
