config_file = File.join(RAILS_ROOT, 'config', 'initializers', 'whistleblower.rb')
unless File::exists? config_file
  File.open(config_file, "w") do |file|
    file.print <<-EOS
Whistleblower::Config.access_key_id = ''
Whistleblower::Config.secret_access_key = ''
EOS
  end
end

puts IO.read(File.join(File.dirname(__FILE__), 'README')) 
puts "\n"
puts IO.read(File.join(File.dirname(__FILE__), 'INSTALL')) 
