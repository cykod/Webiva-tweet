

class Tweet::AdminController < ModuleController

  component_info 'Tweet', :description => 'Twitter support', 
                          :access => :private,
                          :dependencies => ['oauth']

  # Register a handler feature
  register_permission_category :tweet, "Tweet" ,"Permissions related to Tweet"
  
  register_permissions :tweet, [ [ :manage, 'Manage Tweet', 'Manage Tweet' ],
                                  [ :config, 'Configure Tweet', 'Configure Tweet' ]
                                  ]
  permit 'tweet_config'

  register_handler :oauth, :provider, 'TweetOauthProvider'

  cms_admin_paths "options",
                   "Options" =>   { :controller => '/options' },
                   "Modules" =>  { :controller => '/modules' },
                   "Tweet Options" => { :action => 'index' }
 
 public 
 
 def options
    cms_page_path ['Options','Modules'],"Tweet Options"
    
    if params[:options] && params[:options][:user_password].blank?
      @orig_opts = self.class.module_options
      params[:options][:user_password] = @orig_opts.user_password
      
    end
    
    @options = self.class.module_options(params[:options])

    if request.post? && params[:options] && @options.valid?
      Configuration.set_config_model(@options)
      flash[:notice] = "Updated Tweet module options".t 
      redirect_to :controller => '/modules'
      return
    end    
    
    if !request.post?
      @options.user_password = nil
    end 
  
  end
  
  def self.module_options(vals=nil)
    Configuration.get_config_model(Options,vals)
  end
  
  class Options < HashModel
    attributes :user_email => nil, :user_password => nil, :consumer_key => nil, :consumer_secret => nil
  end
  
end
