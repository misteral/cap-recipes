# @author Donovan Bray <donnoman@donovanbray.com>
Capistrano::Configuration.instance(:must_exist).load do

  namespace :bundler do

    set :bundler_opts, %w(--deployment --no-color --quiet)
    set(:bundler_exec) { base_ruby_path + "/bin/bundle" }
    set(:bundler_dir) { "#{shared_path}/bundle" }
    set :bundler_rubygems_minimum_ver, '1.3.7'
    set :bundler_ver, "1.0.15"
    set(:bundler_user) { user }
    set :bundler_file, "Gemfile"
    set :bundler_binstubs, true

    desc "Update Rubygems to be compatible with bundler"
    task :update_rubygems, :except => { :no_release => true } do
      gem_ver = capture("#{base_ruby_path}/bin/gem --version").chomp
      if gem_ver < bundler_rubygems_minimum_ver
        logger.important "RubyGems needs to be udpated, has gem --version #{gem_ver}"
        sudo "#{base_ruby_path}/bin/gem update --system"
      end
    end

    desc "Setup system to use bundler"
    task :install, :except => { :no_release => true } do
      update_rubygems
      utilities.gem_install_only "bundler", bundler_ver
    end

    desc "bundle the release"
    task :configure, :except => { :no_release => true } do

      #Don't bother if there's no gemfile.
      #optionally do it as a specific user to avoid permissions problems
      #do as much as possible in a single 'run' for speed.

      args = bundler_opts
      args << "--path #{bundler_dir}" unless bundler_dir.to_s.empty? || bundler_opts.include?("--system")
      args << "--gemfile=#{bundler_file}" unless bundler_file == "Gemfile"
      args << "--binstubs" if bundler_binstubs

      cmd = "cd #{latest_release}; if [ -f #{bundler_file} ]; then #{bundler_exec} check || #{bundler_exec} install #{args.join(' ')}; fi"
      if bundler_opts.include?('--system')
        cmd = "#{sudo} sh -c '#{cmd}'"
      elsif bundler_user and not bundler_user.empty?
        cmd = "sudo -u #{bundler_user} sh -c '#{cmd}'"
      end
      run cmd

      on_rollback do
        if previous_release
          cmd = "cd #{previous_release}; if [ -f #{bundler_file} ]; then #{bundler_exec} install #{args.join(' ')}; fi"
          if bundler_opts.include?('--system')
            cmd = "#{sudo} sh -c '#{cmd}'"
          elsif bundler_user and not bundler_user.empty?
            cmd = "sudo -u #{bundler_user} sh -c '#{cmd}'"
          end
          run cmd
        else
          logger.important "no previous release to rollback to, rollback of bundler:install skipped"
        end
      end

    end

  end

end
