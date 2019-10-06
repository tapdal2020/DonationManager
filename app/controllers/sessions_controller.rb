class SessionsController < ApplicationController

    def new
        @session = Session.new
    end

    def create
        session_info = params["user"]

        user = User.find_by_email(session_info["email"])
        if user && user.authenticate(session_info["password"])
            session[:user_id] = user.id
            redirect_to 'http://google.com'
        else
            flash.now[:alert] = "Email or password invalid"
            flash.keep
            render 'new'
        end

    end
    
    def current_user 
        @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end
end
