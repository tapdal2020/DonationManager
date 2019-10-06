class UsersController < ApplicationController
    
    def new
        @user = User.new
    end

    def create
        user_info = params["user"]
        @user = User.new(
            first_name: user_info[:first_name],
            last_name: user_info[:last_name],
            email: user_info[:email],
            password: user_info[:password],
            password_confirmation: user_info[:password_confirmation],
            street_address_line_1: user_info[:street_address_line_1],
            city: user_info[:city],
            state: user_info[:state],
            zip_code: user_info[:zip_code],
        )
        
        if @user.save(context: current_user && current_user.admin? ? :admin : :user)
            redirect_to new_session_path
        else
            render :new
        end
    end

    def index

    end

    def show

    end

    def edit

    end

    def update

    end
    
end
