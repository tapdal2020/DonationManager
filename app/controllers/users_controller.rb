class UsersController < ApplicationController
    before_action :authenticate_user!, except: [:new, :create]
    before_action :authenticate_admin!, only: [:index, :get_emails, :generate_email_list]
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
            if current_admin
                redirect_to user_path(current_admin.id) and return
            else
                redirect_to new_session_path and return
            end
        else
            render 'new' and return
        end
    end

    def index
        @users = User.all.order(sort_column + ' ' + sort_direction)
    end

    def show
        request = params[:id].to_i
        with = session[:user_id].to_i
        if request != with
            render 'unauthorized' and return
        else
            @html_donation_title = (is_currently_admin?) ? 'Donation Administrator' : 'Donations Overview'
            # @my_donations = (is_currently_admin?) ? MadeDonation.all : MadeDonation.where("user_id = ?", request)
            # @my_donations = @my_donations.order(sort_column + ' ' + sort_direction)
            # if and admin bring in users to show their email on table
            @my_donations = (is_currently_admin?) ? MadeDonation.joins(:user) : MadeDonation.where("user_id = ?", request).where.not(price: nil)
            @my_recurring = current_user.made_donations.select(:payment_id).where(recurring: true).group(:payment_id).collect { |m| current_user.made_donations.where(parent_txn: m.payment_id).or(current_user.made_donations.where(payment_id: m.payment_id)).order(created_at: :desc).to_a.values_at(0, -1) }
            current_user.made_donations.select(:payment_id).where(recurring: true).group(:payment_id).each do |m|
                puts "#{m.payment_id}"
            end
            puts @my_recurring.empty?
            @donations_chart = @my_donations.monthly_donations
            @my_donations = @my_donations.order(sort_column + ' ' + sort_direction)
        end
    end

    def edit
        request = params[:id].to_i
        with = session[:user_id].to_i
        if request != with && !current_admin
            render 'unauthorized' and return
        end

        @user = User.find(params[:id])
    end

    def change_password
        edit
    end

    def update
        request = params[:id].to_i
        with = session[:user_id].to_i
        if request != with && !current_admin
            render 'unauthorized' and return
        end
        
        @user = User.find(params[:id])
        if @user.update(update_params)
            redirect_to (is_currently_admin?) ? users_path : user_path(current_user.id) and return
        else
            render 'edit' and return
        end
    end

    def update_password
        request = params[:id].to_i
        with = session[:user_id].to_i
        if request != with
            render 'unauthorized' and return
        end

        @user = User.find(params[:id])
        new_info = params["user"]
        if @user && @user.authenticate(new_info[:old_password])
            if new_info[:password] == new_info[:password_confirmation]
                if @user.update(new_password_params)
                    redirect_to user_path(@user.id) and return
                else
                    flash.now["alert"] = "Failed to update password"
                    render 'change_password' and return
                end
            else
                flash.now["alert"] = "Failed to update password"
                render 'change_password' and return
            end
        else
            flash.now["alert"] = "Failed to update password"
            render 'change_password' and return
        end
    end

    def destroy
        request = params[:id].to_i
        with = session[:user_id].to_i
        if request != with && !current_admin
            render 'unauthorized' and return
        end

        @user = User.find(params[:id])

        unless @user.made_donations.where(recurring: true).empty?
            flash[:notice] = "Please delete your recurring donations before deleting your account."
            flash.keep
            render 'edit' and return
        end

        if @user.destroy
            redirect_to (is_currently_admin?) ? users_path : user_path(current_user.id) and return
        else
            render 'edit' and return
        end
    end

    def get_emails
        @users = User.all
        @user = current_admin
        @names = ['None'] + PLAN_CONFIG.collect { |h, v| v["name"] }
        @memberships = session[:memberships]
    end

    def generate_email_list
        if params[:subset]
            @memberships = params[:subset]["memberships"]
        else
            @memberships = ['None'] + PLAN_CONFIG.collect { |h, v| v["name"] }
        end
        session[:memberships] = @memberships

        @users = User.where({ membership: @memberships.collect { |m| m } })
        respond_to do |format|
            format.html
            format.csv { send_data @users.to_csv, filename: "users-#{Date.today}-#{@memberships.join ''}.csv" }
        end
    end

    helper_method :is_currently_admin?
    def is_currently_admin?
        User.find(params[:id]).admin?
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
        %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
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
            params.require("user").permit(:first_name, :last_name, :email, :street_address_line_1, :city, :state, :zip_code, :street_address_line_2, :membership, :admin)
        else
            params.require("user").permit(:first_name, :last_name, :email, :street_address_line_1, :city, :state, :zip_code, :street_address_line_2, :membership)
        end
    end

    def new_password_params
        params.require("user").permit(:password, :password_confirmation)
    end
    
end
