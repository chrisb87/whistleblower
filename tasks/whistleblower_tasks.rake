namespace :whistleblower do

  desc 'Validates a list of alerts supplied through ALERTS argument'
  task :validate => :environment do |t, args|
    raise Exception.new("Requires a list of alert names as ALERTS argument") unless ENV['ALERTS']
    alert_names = ENV['ALERTS'].split(',').map(&:strip)
    alert_names.each {|alert_name| validate_alert alert_name}
  end
  
  desc 'Clears all current alerts'
  task :clear_alerts => :environment do |t, args|
    Whistleblower::Alert.db.query(Whistleblower::WHISTLEBLOWER_ALERTS_DOMAIN, '')[:items].each do |alert_name|
      Whistleblower::Alert.db.delete_attributes Whistleblower::WHISTLEBLOWER_ALERTS_DOMAIN, alert_name
    end
  end
  
  desc 'Clears all alert logs'
  task :clear_logs => :environment do |t, args|
    Whistleblower::Alert.db.query(Whistleblower::WHISTLEBLOWER_ALERT_LOGS_DOMAIN, '')[:items].each do |log_name|
      Whistleblower::Alert.db.delete_attributes Whistleblower::WHISTLEBLOWER_ALERT_LOGS_DOMAIN, log_name
    end
  end
  
end

def validate_alert(alert_name)
  puts "Validating #{alert_name}..."
  begin
    alert = alert_name.to_s.constantize
    passed = alert.validate
    puts "\t" + (passed ? 'passed' : 'failed!')
  rescue NameError => e
    puts "\tfailed! Could not find alert with this name"
  end
end
