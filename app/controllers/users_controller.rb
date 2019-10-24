class UsersController < ApplicationController
    before_action :authenticate_user!, except: [:new, :create]
    helper_method :sort_column, :sort_direction
    
    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        
        if @user.save(context: current_admin ? :admin : :user)
            redirect_to new_session_path
        else
            render 'new'
        end
    end

    def index
        #puts 'calling user#index function'
        return @user = User.all.order(:last_name)
    end

    def show
        # make sure the user is NOT accessing another user's page
        request = params[:id].to_i
        with = session[:user_id].to_i
        if (request != with)
            render 'unauthorized'
        else
            @html_donation_title = (is_currently_admin?) ? 'Donation Administrator' : 'Donations Overview'
            @my_donations = (is_currently_admin?) ? MadeDonation.all : MadeDonation.where("user_id = ?", request)
            @my_donations = @my_donations.order(sort_column + ' ' + sort_direction)
        end
    end

    def edit

    end

    def update

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

    def user_params
        if current_admin
            params.require("user").permit(:email, :password, :password_confirmation, :admin)
        else
            params.require("user").permit(:first_name, :last_name, :email, :password, :password_confirmation, :street_address_line_1, :city, :state, :zip_code, :street_address_line_2)
        end
    end
    
end
