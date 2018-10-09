module ApplicationHelper
  def personalize_script
    path = File.expand_path("../../scripts/personalize/#{ENV['USER']}.sh", __FILE__)
    if File.exist?(path)
      script =<<EOL
#######################################
# personalize script added by ApplicationHelper#personalize_script for #{ENV['USER']}
/opt/scripts/personalize/tung.sh
EOL
    end
  end
end
