class SessionsController < ApplicationController

    def create
        session_info = params["user"]

        user = User.find_by_email(session_info["email"])
        if user && user.authenticate(session_info["password"])
            session[:user_id] = user.id
            session[:last_access] = Time.now
            redirect_to new_donation_transaction_path
        else
            flash.now[:alert] = "Email or password invalid"
            flash.keep
            render 'new'
        end
    end
end
