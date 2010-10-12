class WhistleblowerAlertGenerator < Rails::Generator::NamedBase
  
  def manifest
    record do |m|
      @name = @name + '_alert'
      m.directory "lib/alerts"
      m.template 'alert.rb', "lib/alerts/#{@singular_name}_alert.rb"
    end
  end
  
end
