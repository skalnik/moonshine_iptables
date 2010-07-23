module Moonshine
  module Iptables
    class CapistranoIntegration
      def self.load_callbacks_into(capistrano_config)
        capistrano_config.load do
          after 'deploy:cleanup', 'iptables:reset_rules'
        end
      end

      def self.load_into(capistrano_config)
        load_callbacks_into(capistrano_config)

        capistrano_config.load do
          namespace :iptables do
            desc 'Drops all Iptables rules and then readds them.'
            task :reset_rules do
              sudo "'#{['iptables -F',
                        'iptables -X',
                        'iptables -t nat -F',
                        'iptables -t nat -X',
                        'iptables -t mangle -F',
                        'iptables -t mangle -X'].join(' && ')}'"
              sudo 'iptables-restore < /etc/iptables.rules'
            end
          end
        end
      end
    end
  end
end
require 'capistrano'
if Capistrano::Configuration.instance
  Moonshine::Iptables::CapistranoIntegration.load_into(Capistrano::Configuration.instance)
end

