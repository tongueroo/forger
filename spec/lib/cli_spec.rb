describe Forger::CLI do
  before(:all) do
    @args = "--noop"
  end

  describe "forger" do
    it "create" do
      out = execute("exe/forger create server #{@args}")
      expect(out).to include("Creating EC2 instance")
    end

    it "ami" do
      out = execute("exe/forger ami myimage #{@args}")
      expect(out).to include("Creating EC2 instance")
    end

    it "wait ami" do
      out = execute("exe/forger wait ami myimage")
      expect(out).to include("Waiting for")
    end

    it "clean ami" do
      out = execute("exe/forger clean ami imagebasename")
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
        out = execute("exe/forger completion #{command}")
        expect(out).to include(expected_word) # only checking for one word for simplicity
      end
    end
  end
end
