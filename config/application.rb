require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env)

module Myflix
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true

    config.autoload_paths += %W(#{config.root}/lib)
    
    config.action_mailer.default_url_options = { host: Rails.env.production? ? 'intense-oasis-3523.herokuapp.com' : 'localhost:3000' }
    
    config.assets.enabled = true
    config.generators do |g|
      g.orm :active_record
      g.template_engine :haml
    end
  end
end
