class UsersController < ApplicationController
    
    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        
        if @user.save
            redirect_to new_session_path
        else
            render 'new'
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

    private

    def user_params
        params.require("user").permit(:first_name, :last_name, :email, :password, :password_confirmation, :street_address_line_1, :city, :state, :zip_code, :street_address_line_2)
    end
    
end
