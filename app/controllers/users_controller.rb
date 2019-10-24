class UsersController < ApplicationController
    before_action :authenticate_user!, except: [:new, :create]
    before_action :authenticate_admin!, only: [:index]
    helper_method :sort_column, :sort_direction
    
    def new
        @user = User.new
    end

    def create
        if current_user && !current_user.admin?
            redirect_to user_path(session[:user_id]) and return
        end

        if !params["user"][:admin].nil? && !current_user
            redirect_to new_session_path and return
        end

        @user = User.new(user_params)
        
        if @user.save(context: current_admin ? :admin : :user)
            redirect_to new_session_path and return
        else
            render 'new' and return
        end
    end

    def index
        #puts 'calling user#index function'
        return @user = User.all.order(:last_name)
    end

    def show
        # make sure the user is NOT accessing another user's page
        # but allow admin to do so
        request = params[:id].to_i
        with = session[:user_id].to_i
        if request != with && !current_admin
            render 'unauthorized' and return
        else
            @html_donation_title = (is_currently_admin?) ? 'Donation Administrator' : 'Donations Overview'
            @my_donations = (is_currently_admin?) ? MadeDonation.all : MadeDonation.where("user_id = ?", request)
            @my_donations = @my_donations.order(sort_column + ' ' + sort_direction)
        end
    end

    def edit
        request = params[:id].to_i
        with = session[:user_id].to_i
        if request != with && !current_admin
            render 'unauthorized' and return
        end

        @user = user.find(params[:id])
    end

    def update
        request = params[:id].to_i
        with = session[:user_id].to_i
        if request != with && !current_admin
            render 'unauthorized' and return
        end
        
        @user.save(update_params)
    end

    def is_currently_admin?
        User.find(params[:id]).admin?
    end

    private
    def sort_column
        MadeDonation.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end
    def sort_direction
        %w[asc desc].include?(params[:direction]) ?  params[:direction] : "desc"
    end

    def is_currently_admin?
        current_admin
    end

    def user_params
        if current_admin
            params.require("user").permit(:email, :password, :password_confirmation, :admin)
        else
            params.require("user").permit(:first_name, :last_name, :email, :password, :password_confirmation, :street_address_line_1, :city, :state, :zip_code, :street_address_line_2)
        end
    end

    def update_params
        if current_admin
            params.require("user").permit(:first_name, :last_name, :email, :street_address_line_1, :city, :state, :zip_code, :street_address_line_2, :admin)
        else
            params.require("user").permit(:first_name, :last_name, :email, :street_address_line_1, :city, :state, :zip_code, :street_address_line_2)
        end
    end
    
end
