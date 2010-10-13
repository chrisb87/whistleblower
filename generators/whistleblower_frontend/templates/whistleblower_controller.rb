class <%= class_name %>Controller < ApplicationController
  
  def index
    @alerts = {}
    
    Whistleblower.db.query(Whistleblower::ALERTS_DOMAIN, '')[:items].each do |alert_name|
      @alerts[alert_name] = Whistleblower.db.get_attributes(Whistleblower::ALERTS_DOMAIN, alert_name)[:attributes]
    end
  
    respond_to do |format|
      format.html # index.html.erb
      #format.xml  { render :xml => @alerts }
    end
  end
  
  def logs
    @alert_name = params[:id]
    @logs = []
    Whistleblower.db.query(Whistleblower::ALERT_LOGS_DOMAIN, "['alert_name' = '#{@alert_name}']")[:items].each do |log_uuid|
      log_attributes = Whistleblower.db.get_attributes(Whistleblower::ALERT_LOGS_DOMAIN, log_uuid)[:attributes]
      log_attributes['uuid'] = log_uuid
      @logs << log_attributes
    end
    @logs = @logs.sort_by{|log| log['raised_at'].first}
    
    debugger
    
     respond_to do |format|
       format.html # show.html.erb
       #format.xml  { render :xml => @logs }
     end
  end

end
