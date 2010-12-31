

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
    
    @options = self.class.module_options(params[:options])

    if request.post? && params[:options] && @options.valid?
      Configuration.set_config_model(@options)
      flash[:notice] = "Updated Tweet module options".t 
      redirect_to :controller => '/modules'
      return
    end    
  end

  def login
    self.provider.redirect_uri = url_for :action => 'setup'
    redirect_to self.provider.authorize_url
  end

  def setup
    if self.provider.access_token(params)
      @options = self.class.module_options
      @options.oauth_token = @provider.token
      Configuration.set_config_model(@options)
      flash[:notice] = 'Saved twitter credentials'
    else
      flash[:notice] = 'Twitter login failed'
    end

    redirect_to :action => 'options'
  end

  def self.module_options(vals=nil)
    Configuration.get_config_model(Options,vals)
  end
  
  class Options < HashModel
    attributes :consumer_key => nil, :consumer_secret => nil, :oauth_token => nil
  end

  protected

  def provider
    @provider ||= OauthProvider::Base.provider('twitter', session)
  end

  def oauth_user
    @oauth_user ||= self.provider.push_oauth_user(myself)
  end
end
