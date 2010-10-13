class WhistleblowerFrontendGenerator < Rails::Generator::NamedBase
  
  def manifest
    record do |m|
      m.directory "app/controllers"
      m.template "whistleblower_controller.rb", "app/controllers/#{@singular_name}_controller.rb"
      m.directory "app/views/#{@singular_name}"
      m.file 'index.html.erb', "app/views/#{@singular_name}/index.html.erb"
      m.file 'logs.html.erb', "app/views/#{@singular_name}/logs.html.erb"
    end
  end
  
end
