require 'right_aws'
require 'uuidtools'

module Whistleblower
  ALERTS_DOMAIN = 'whistleblower_alerts'
  ALERT_LOGS_DOMAIN = 'whistleblower_alert_logs'
  
  def self.db
    unless defined? @@db
      debugger
      @@db = RightAws::SdbInterface.new(Whistleblower::Config.access_key_id, Whistleblower::Config.secret_access_key)
      [ALERTS_DOMAIN, ALERT_LOGS_DOMAIN].each do |domain|
        @@db.create_domain(domain)
      end
    end
    @@db
  end
  
  class Alert

    def self.validate
      errors = {}
      validation_time = DateTime.now
      
      methods.select{|method| method =~ /validate_.+/}.each do |method|
        result = send method
        errors[method] = result unless result.blank?
      end
      
      if errors.blank?
        if raised?
          last_uuid = self.uuid
          resolve_alert(validation_time)
          on_resolved(last_uuid, validation_time)
        end
      else
        if raised?
          sustain_alert(errors, validation_time)
          on_sustained(errors, validation_time)
        else
          raise_alert(errors, validation_time)
          while self.uuid.blank?
             sleep(0.1)
           end
          on_raised(errors, validation_time)
        end
      end
      
      errors.blank? ? true : false
    end
    
    def self.alert_name
      Rails.env.production? ? self.to_s : self.to_s + '_' + Rails.env
    end
    
    def self.create_error_report(errors)
      errors.map{|k,v| "#{k} failed at #{DateTime.now.to_s}. Returned: #{v}"}.join('. ')[0..1023]
    end
    
    def self.raised?
      attributes = Whistleblower.db.get_attributes(ALERTS_DOMAIN, alert_name)[:attributes]
      (attributes.blank? or attributes['raised'].first == 'false') ? false : true
    end
    
    def self.last_raised_at
      Whistleblower.db.get_attributes(ALERTS_DOMAIN, alert_name)[:attributes]['last_raised_at'].first
    end
    
    def self.last_sustained_at
      Whistleblower.db.get_attributes(ALERTS_DOMAIN, alert_name)[:attributes]['last_sustained_at'].first
    end
    
    def self.uuid
      return nil if not self.raised?
      attributes = Whistleblower.db.get_attributes(ALERTS_DOMAIN, alert_name)[:attributes]
      (attributes.blank? or attributes['uuid'].first.blank?) ? nil : attributes['uuid'].first
    end
    
    def self.raise_alert(errors, validation_time)
      raise 'Raising an alert that is already raised' if self.raised?
      attributes = {:raised => true, 
        :last_raised_at => validation_time, 
        :details => create_error_report(errors),
        :uuid => UUIDTools::UUID.random_create.to_s}
      Whistleblower.db.put_attributes(ALERTS_DOMAIN, alert_name, attributes, replace=true)
    end
    
    def self.on_raised(errors, validation_time); end
    
    def self.sustain_alert(errors, validation_time)
      raise 'Sustaining an alert that is not raised' if not self.raised?
      Whistleblower.db.put_attributes(ALERTS_DOMAIN, alert_name, {:details => create_error_report(errors)}, replace=false)
      Whistleblower.db.put_attributes(ALERTS_DOMAIN, alert_name, {:last_sustained_at => validation_time}, replace=true)
    end
    
    def self.on_sustained(errors, validation_time); end
    
    def self.resolve_alert(validation_time)
      attributes = Whistleblower.db.get_attributes(ALERTS_DOMAIN, alert_name)[:attributes]
      details = attributes['details']
      log_uuid = attributes['uuid']
      
      Whistleblower.db.put_attributes(ALERT_LOGS_DOMAIN, log_uuid, 
        {:alert_name => alert_name,
          :raised_at => last_raised_at,
          :resolved_at => validation_time,
          :details => details}, replace=false)
          
      Whistleblower.db.put_attributes(ALERTS_DOMAIN, alert_name, 
        {:raised => false, 
          :uuid => nil, 
          :details => nil}, replace=true)
      
      return log_uuid, attributes
    end
    
    def self.on_resolved(uuid, validation_time); end

    def self.validates_greater_than(value1, value2)
      class_eval(<<-EOS)
        class << self
          def validate_#{value1}_greater_than_#{value2}
            v1, v2 = #{value1}, #{value2}
            (v1>v2) ? nil : "\#{v1} is not greater than \#{v2}"
          end
        end
      EOS
    end
    
    def self.validates_greater_than_or_equal_to(value1, value2)
      class_eval(<<-EOS)
        class << self
          def validate_#{value1}_greater_than_or_equal_to_#{value2}
            v1, v2 = #{value1}, #{value2}
            (v1>=v2) ? nil : "\#{v1} is not greater than or equal to \#{v2}"
          end
        end
      EOS
    end
    
    def self.validates_less_than(value1, value2)
      class_eval(<<-EOS)
        class << self
          def validate_#{value1}_less_than_#{value2}
            v1, v2 = #{value1}, #{value2}
            (v1<v2) ? nil : "\#{v1} is not less than \#{v2}"
          end
        end
      EOS
    end
    
    def self.validates_less_than_or_equal_to(value1, value2)
      class_eval(<<-EOS)
        class << self
          def validate_#{value1}_less_than_or_equal_to_#{value2}
            v1, v2 = #{value1}, #{value2}
            (v1<=v2) ? nil : "\#{v1} is not less than or equal to \#{v2}"
          end
        end
      EOS
    end
    
    def self.validates_equal(*args)
      validator_name = "validate_" + args.join('_equals_')
      values_string = '{' + args.map{|a| '"' + a.to_s + '"' + ' => ' + a.to_s}.join(',') + '}'
      validator_method = <<-EOS
        class << self
          def #{validator_name}
            values = #{values_string}
            unless values.values.all?{|arg| arg == values.values.first}
              values.map{|k,v| "\#{k} = \#{v}"}.join(', ')
            end
          end
        end
      EOS
      class_eval(validator_method)
    end
    
    def self.deliver_alert_raised_emails(recipients, errors, validation_failed_at)
      WhistleblowerMailer.deliver_alert_raised(recipients, alert_name, uuid, errors, validation_failed_at)
    end
    
    def self.deliver_alert_sustained_emails(recipients, errors, validation_failed_at)
      WhistleblowerMailer.deliver_alert_sustained(recipients, alert_name, uuid, errors, validation_failed_at)
    end
    
    def self.deliver_alert_resolved_emails(recipients, log_uuid, validations_passed_at)
      WhistleblowerMailer.deliver_alert_resolved(recipients, alert_name, log_uuid, validations_passed_at)
    end

  end

end
