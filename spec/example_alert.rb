class ExampleAlert < Whistleblower::Alert
  EMAIL_RECIPIENTS = ["recipient@example.com"]
  
  # An example of a simple built-in validation
  validates_less_than_or_equal_to :foo, 1000
  def self.foo; 100; end
  
  # More complex validations can be defined as any method that begins in "validate_"
  # If anything other than nil is returned, the validation fails
  def self.validate_basic_math
    1==1 ? nil : 'Math error, 1 != 1'
  end
  
  # These callbacks can be used to perform actions when alerts are raised, sustained, and lowered
  
  def self.on_raised(errors, validation_time)
    deliver_alert_raised_emails(EMAIL_RECIPIENTS, errors, validation_time)
  end
  
  def self.on_sustained(errors, validation_time)
    deliver_alert_sustained_emails(EMAIL_RECIPIENTS, errors, validation_time)
  end
  
  def self.on_resolved(uuid, validation_time)
    deliver_alert_resolved_emails(EMAIL_RECIPIENTS, uuid, validation_time)
  end
  
end
