[:AWS_ACCESS_KEY_ID, :AWS_SECRET_ACCESS_KEY].each do |constant|
  raise "Whistleblower requires constant #{constant}, which is not defined in the current environment (#{RAILS_ENV})." unless Object.const_defined? constant
end

$:.unshift(File.expand_path(RAILS_ROOT) + '/vendor/plugins/whistleblower/')
ActiveSupport::Dependencies.load_paths << "#{RAILS_ROOT}/lib/alerts"
