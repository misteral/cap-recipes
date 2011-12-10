# Allows Tasks that have no servers to be skipped instead of raising a NoMatchingServersError

module Capistrano
  class Configuration
    module Connections
      def execute_on_servers(options={})
        raise ArgumentError, "expected a block" unless block_given?

        if task = current_task
          servers = find_servers_for_task(task, options)

          if servers.empty?
            #raise Capistrano::NoMatchingServersError, "`#{task.fully_qualified_name}' is only run for servers matching #{task.options.inspect}, but no servers matched"
            logger.info "skipping `#{task.fully_qualified_name}' because no servers matched"
            return
          end

          if task.continue_on_error?
            servers.delete_if { |s| has_failed?(s) }
            return if servers.empty?
          end
        else
          servers = find_servers(options)
          raise Capistrano::NoMatchingServersError, "no servers found to match #{options.inspect}" if servers.empty?
        end

        servers = [servers.first] if options[:once]
        logger.trace "servers: #{servers.map { |s| s.host }.inspect}"

        max_hosts = (options[:max_hosts] || (task && task.max_hosts) || servers.size).to_i
        is_subset = max_hosts < servers.size

        # establish connections to those servers in groups of max_hosts, as necessary
        servers.each_slice(max_hosts) do |servers_slice|
          begin
            establish_connections_to(servers_slice)
          rescue ConnectionError => error
            raise error unless task && task.continue_on_error?
            error.hosts.each do |h|
              servers_slice.delete(h)
              failed!(h)
            end
          end

          begin
            yield servers_slice
          rescue RemoteError => error
            raise error unless task && task.continue_on_error?
            error.hosts.each { |h| failed!(h) }
          end

          # if dealing with a subset (e.g., :max_hosts is less than the
          # number of servers available) teardown the subset of connections
          # that were just made, so that we can make room for the next subset.
          teardown_connections_to(servers_slice) if is_subset
        end
      end
    end
  end
end