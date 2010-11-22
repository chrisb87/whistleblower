namespace :whistleblower do

  desc 'Validates a list of alerts supplied through ALERTS argument'
  task :validate => :environment do |t, args|
    if ENV['CRON'] and not Rails.env.production?
      raise Exception.new("Abort: must be in production environment when passing the CRON flag. Rails environment is currently #{Rails.env}")
    end
    
    Dir["lib/alerts/*.rb"].each {|file| require file}
    
    if ENV['ALERTS']
      target_alerts = ENV['ALERTS'].split(',').map(&:strip)
    else
      target_alerts = Whistleblower::Alert.subclasses
    end
    
    target_alerts = target_alerts.map{|alert_name| Object::const_get(alert_name)}
    
    target_alerts.each do |target_alert|
      puts "Validating #{target_alert.to_s}..."
      passed = target_alert.validate
      puts "\t" + (passed ? 'passed' : 'failed!')
    end
    
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
