class ApplicationController < ActionController::Base
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
        session[:last_access] && session[:last_access] + 1.hours > Time.now
    end

    def authenticate_user!
        redirect_to new_session_path unless current_user && valid_session
        session[:last_access] = Time.now
    end

    def authenticate_admin!
        redirect_to new_session_path unless current_admin && valid_session
        session[:last_access] = Time.now
    end
end
