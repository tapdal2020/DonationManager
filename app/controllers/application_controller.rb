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
        puts "1: #{session[:last_access]}"
        puts "2: #{1.hours.since(session[:last_access].to_datetime) > Time.now}"
        puts "3: #{session[:rememberme]} #{session[:rememberme].class}"
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
end
