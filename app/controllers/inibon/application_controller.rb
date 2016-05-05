module Inibon

  class ApplicationController < ::ApplicationController

    layout 'application'
    before_filter :set_inibon_version

    def set_inibon_version
      Inibon::ArI18n.display_version = Inibon::Version.find_by_id(session[:display_version])
      Inibon::ArI18n.modify_version = Inibon::Version.find_by_id(session[:modify_version])
    end

  end

end
