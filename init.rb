$:.unshift(File.expand_path(RAILS_ROOT) + '/vendor/plugins/whistleblower/')
ActiveSupport::Dependencies.load_paths << "#{RAILS_ROOT}/lib/alerts"
