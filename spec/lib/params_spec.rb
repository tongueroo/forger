describe Forger::Create::Params do
  let(:param) { Forger::Create::Params.new(name: "myserver") }

  context "completely empty" do
    it '#upsert_name_tag!' do
      params = {}
      result = param.upsert_name_tag!(params)
      # puts "params: #{params.inspect}" # uncomment to see and debug
      expect(result).to eq(
        {"tag_specifications"=>
          [{"resource_type"=>"instance",
            "tags"=>[{"key"=>"Name", "value"=>"myserver"}]}]}
      )
    end
  end

  context "empty tag_specifications" do
    it '#upsert_name_tag!' do
      params = {"tag_specifications" => []}
      result = param.upsert_name_tag!(params)
      # puts "params: #{params.inspect}" # uncomment to see and debug
      expect(result).to eq(
        {"tag_specifications"=>
          [{"resource_type"=>"instance",
            "tags"=>[{"key"=>"Name", "value"=>"myserver"}]}]}
      )
    end
  end

  context "contains 1 instance with name" do
    it '#upsert_name_tag!' do
      params = { "tag_specifications" =>
        [{
          "resource_type"=>"instance",
          "tags"=> [{"key"=>"Name", "value"=>"override-myserver"} ]
        }]
      }
      result = param.upsert_name_tag!(params)
      # puts "params: #{params.inspect}" # uncomment to see and debug
      expect(result).to eq(
        {"tag_specifications"=>
          [{"resource_type"=>"instance",
            "tags"=>[{"key"=>"Name", "value"=>"override-myserver"}]}]}
      )
    end
  end

  context "contains 1 instance with non-name tag" do
    it '#upsert_name_tag!' do
      params = { "tag_specifications" =>
        [{
          "resource_type"=>"instance",
          "tags"=> [{"key"=>"Os", "value"=>"amazonlinux"} ]
        }]
      }
      result = param.upsert_name_tag!(params)
      # puts "params: #{params.inspect}" # uncomment to see and debug
      expect(result).to eq(
        { "tag_specifications" =>
          [{
            "resource_type"=>"instance",
            "tags"=> [
              {"key"=>"Os", "value"=>"amazonlinux"},
              {"key"=>"Name", "value"=>"myserver"},
            ]
          }]
        }
      )
    end
  end
end
