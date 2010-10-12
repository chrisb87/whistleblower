class WhistleblowerMailer < ActionMailer::Base
  
  def alert_raised(recipients, alert_name, uuid, errors, validation_time)
    subject       "[Whistleblower] #{alert_name} raised (#{uuid})"
    from          "Whistleblower"
    recipients    recipients
    body          :alert_name => alert_name, :errors => errors, :uuid => uuid, :validation_time => validation_time
    content_type  "text/html"
  end
  
  def alert_sustained(recipients, alert_name, uuid, errors, validation_time)
    subject       "[Whistleblower] #{alert_name} raised (#{uuid})"
    from          "Whistleblower"
    recipients    recipients
    body          :alert_name => alert_name, :errors => errors, :uuid => uuid, :validation_time => validation_time
    content_type  "text/html"
  end
  
  def alert_resolved(recipients, alert_name, uuid, validation_time)
    subject       "[Whistleblower] #{alert_name} raised (#{uuid})"
    from          "Whistleblower"
    recipients    recipients
    body          :alert_name => alert_name, :uuid => uuid, :validation_time => validation_time
    content_type  "text/html"
  end
  
end
