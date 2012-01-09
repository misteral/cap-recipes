Capistrano::Configuration.instance(true).load do

  namespace :ssh do
    set :issue_net, File.join(File.dirname(__FILE__),'issue.net')
    set :sshd_config, File.join(File.dirname(__FILE__),'sshd_config')

    desc "Setup and Configure issue.net and sshd_config"
    task :install_issue do
      utilities.sudo_upload_template, issue_net, "/etc/issue.net", :mode => "644", :owner => 'root:root'
      utilities.sudo_upload_template, sshd_config, "/etc/ssh/sshd_config", :mode => "644", :owner => 'root:root'
      sudo "sed -i s/#Banner \/etc\/issue.net/Banner \/etc\/issue.net/g /etc/ssh/sshd_config"
      sudo "sed -i s/PrintLastLog yes/PrintLastLog no/g /etc/ssh/sshd_config"
    end

    desc "Restart SSH"
    task :restart do
      utilities.run_compressed %Q{
        #{sudo} /etc/init.d/ssh restart
      }
    end
  end
end