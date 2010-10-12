File.open(File.join(RAILS_ROOT, 'config', 'initializers', 'whistleblower.rb'), "w") do |file|
  file.print <<-EOS
Whistleblower::Config.access_key_id = ''
Whistleblower::Config.secred_access_key = ''
EOS
end

puts IO.read(File.join(File.dirname(__FILE__), 'INSTALL')) 
