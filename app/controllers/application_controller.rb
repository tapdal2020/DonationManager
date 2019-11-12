class ApplicationController < ActionController::Base
    # test for any user logging out then clicking back and seeing their donations
    before_action :set_cache_crusher
    protect_from_forgery with: :exception

    helper_method :current_user
    def current_user 
        @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def current_admin
        @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
        return @current_user if @current_user && @current_user.admin
    end

    def valid_session
        session[:last_access] && ((1.hours.since(session[:last_access].to_datetime) > Time.now) || session[:rememberme] == "1")
    end

    def authenticate_user!
        unless current_user && valid_session
            session[:user_id] = nil
            session[:last_access] = nil
            redirect_to new_session_path and return
        end
        session[:last_access] = Time.now
    end

    def authenticate_admin!
        unless current_admin && valid_session
            session[:user_id] = nil
            session[:last_access] = nil
            redirect_to new_session_path and return
        end
        session[:last_access] = Time.now
    end

    def set_cache_crusher
        response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
end
