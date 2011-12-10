module Capistrano
  class Configuration
    module Servers
      # Identifies all servers that the given task should be executed on.
      # The options hash accepts the same arguments as #find_servers, and any
      # preexisting options there will take precedence over the options in
      # the task.
      def find_servers_for_task(task, options={})
        find_servers(task.options.merge(options))
      end

      # Attempts to find all defined servers that match the given criteria.
      # The options hash may include a :hosts option (which should specify
      # an array of host names or ServerDefinition instances), a :roles
      # option (specifying an array of roles), an :only option (specifying
      # a hash of key/value pairs that any matching server must match), and
      # an :exception option (like :only, but the inverse).
      #
      # Additionally, if the HOSTS environment variable is set, it will take
      # precedence over any other options. Similarly, the ROLES environment
      # variable will take precedence over other options. If both HOSTS and
      # ROLES are given, HOSTS wins.
      #
      # Yet additionally, if the HOSTFILTER environment variable is set, it
      # will limit the result to hosts found in that (comma-separated) list.
      #
      # Usage:
      #
      #   # return all known servers
      #   servers = find_servers
      #
      #   # find all servers in the app role that are not exempted from
      #   # deployment
      #   servers = find_servers :roles => :app,
      #                :except => { :no_release => true }
      #
      #   # returns the given hosts, translated to ServerDefinition objects
      #   servers = find_servers :hosts => "jamis@example.host.com"
      def find_servers(options={})
        hosts  = server_list_from(ENV['HOSTS'] || options[:hosts])

        if hosts.any?
          filter_server_list(hosts.uniq)
        else
          roles  = role_list_from(ENV['ROLES'] || options[:roles] || self.roles.keys)
          only   = options[:only] || {}
          except = options[:except] || {}

          servers = roles.inject([]) { |list, role| list.concat(self.roles[role]) }
          servers = servers.select { |server| only.all? { |key,value| server.options[key] == value } }
          servers = servers.reject { |server| except.any? { |key,value| server.options[key] == value } }

          #allows you to add the option :once to a task ie: task :my_task, :roles => :app, :once => true do ...
          servers = [servers.first] if options[:once] and servers.size > 1
          logger.trace "servers: #{servers.map { |s| s.host }.inspect}"

          filter_server_list(servers.uniq)
        end
      end
    end
  end
end