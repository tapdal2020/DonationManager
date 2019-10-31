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
        puts 'calling user#index function'
    end

    def show
        # make sure the user is NOT accessing another user's page
        request = params[:id].to_i
        with = session[:user_id].to_i
        if (request != with)
            render 'unauthorized'
        else
            @present_admin = is_currently_admin?
            @html_donation_title = (is_currently_admin?) ? 'Donation Administrator' : 'Donations Overview'
            # if and admin bring in users to show their email on table
            @my_donations = (is_currently_admin?) ? MadeDonation.joins(:user) : MadeDonation.where("user_id = ?", request)
            @donations_chart = @my_donations.monthly_donations
            @my_donations = @my_donations.order(sort_column + ' ' + sort_direction)
        end
    end

    def edit

    end

    def update

    end

    private
    def sort_column
        if !is_currently_admin?
            MadeDonation.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
        else
            # gather the user columns too
            (MadeDonation.column_names + User.column_names).include?(params[:sort]) ? params[:sort] : "created_at"
        end
    end
    def sort_direction
        %w[asc desc].include?(params[:direction]) ?  params[:direction] : "desc"
    end

    def is_currently_admin?
        User.find(params[:id]).admin?
    end

    def user_params
        if current_admin
            params.require("user").permit(:email, :password, :password_confirmation, :admin)
        else
            params.require("user").permit(:first_name, :last_name, :email, :password, :password_confirmation, :street_address_line_1, :city, :state, :zip_code, :street_address_line_2)
        end
    end
    
end
