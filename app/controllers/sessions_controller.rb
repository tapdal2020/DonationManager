class SessionsController < ApplicationController

    def new
        
    end

    def create
        session_info = params["user"]

        user = User.find_by_email(session_info["email"])
        if user && user.authenticate(session_info["password"])
            session[:user_id] = user.id
            redirect_to new_donation_transaction_path
        else
            flash.now[:alert] = "Email or password invalid"
            flash.keep
            render 'new'
        end
    end
end
