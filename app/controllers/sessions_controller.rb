class SessionsController < ApplicationController
    def new
        if current_user
            redirect_to user_path(current_user.id) and return
        end
    end

    def create
        session_info = params["user"]

        user = User.find_by_email(session_info["email"])
        if user && user.authenticate(session_info["password"])
            session[:user_id] = user.id
            session[:last_access] = Time.now
            redirect_to user_path(user.id)
        else
            flash.now[:alert] = "Email or password invalid"
            flash.keep
            render 'new'
        end
    end

    def destroy
        puts "I got called"
        session[:user_id] = nil
        session[:last_access] = nil
        redirect_to new_session_path and return
    end

end
