namespace :whistleblower do

  desc 'Validates a list of alerts supplied through ALERTS argument'
  task :validate => :environment do |t, args|
    if ENV['CRON'] and not Rails.env.production?
      raise Exception.new("Abort: run via CRON in #{Rails.env} environment")
    end
    
    Dir["lib/alerts/*.rb"].each {|file| require file}
    
    if ENV['ALERTS']
      alert_names = ENV['ALERTS'].split(',').map(&:strip)
    else
      alert_names = Whistleblower::Alert.subclasses
    end
    
    alert_names.each {|alert_name| validate_alert alert_name}
  end
  
  desc 'Clears all current alerts'
  task :clear_alerts => :environment do |t, args|
    Whistleblower.db.query(Whistleblower::ALERTS_DOMAIN, '')[:items].each do |alert_name|
      Whistleblower.db.delete_attributes Whistleblower::ALERTS_DOMAIN, alert_name
    end
  end
  
  desc 'Clears all alert logs'
  task :clear_logs => :environment do |t, args|
    Whistleblower.db.query(Whistleblower::ALERT_LOGS_DOMAIN, '')[:items].each do |log_name|
      Whistleblower.db.delete_attributes Whistleblower::ALERT_LOGS_DOMAIN, log_name
    end
  end
  
end

def validate_alert(alert_name)
  puts "Validating #{alert_name}..."
  alert = Object::const_get(alert_name.to_s)
  passed = alert.validate
  puts "\t" + (passed ? 'passed' : 'failed!')
end
