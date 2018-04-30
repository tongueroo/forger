describe Forger::Template::Helper::CoreHelper do
  let(:thing) do
    thing = Class.new
    Forger::Template::Helper::CoreHelper.send :public, :normalize_user_data_name_input
    thing.extend(Forger::Template::Helper::CoreHelper)
    thing
  end

  it 'normalize user_data name input' do
    result = thing.normalize_user_data_name_input("ecs.sh")
    expect(result).to eq "ecs.sh"

    result = thing.normalize_user_data_name_input("ecs")
    expect(result).to eq "ecs.sh"

    result = thing.normalize_user_data_name_input("test/ecs")
    expect(result).to eq "test/ecs.sh"
  end
end
