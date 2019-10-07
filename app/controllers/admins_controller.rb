class AdminsController < ApplicationController
    before_action :authenticate_admin!

    def new
        @admin = Admin.new
    end

    def create
        @admin = Admin.new(admin_params)

        if @admin.save
            redirect_to new_session_path
        else
            render 'new'
        end
    end

    def index

    end

    def show

    end

    def destroy

    end
    
    def delete

    end

    private

    def admin_params
        params.require("admin").permit(:email, :password, :password_confirmation)
    end

end
