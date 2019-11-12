class ReceiptsController < ApplicationController
    before_action :authenticate_user!, except: [:new, :create]

    def index
        @donations = current_user.made_donations

        respond_to do |format|
            format.html
            format.pdf do
                render pdf: "#{current_user.id}_#{Time.now.to_formatted_s(:number)}", :template => 'receipts/index.html.erb'
            end
        end
    end

    def show
        @donation = MadeDonation.find(params[:id])

        respond_to do |format|
            format.html
            format.pdf do
                render pdf: "#{current_user.id}_#{params[:id]}_#{Time.now.to_formatted_s(:number)}", :template => 'receipts/show.html.erb'
            end
        end
    end

    private

    helper_method :total
    def total
        @donations.sum(:price)
    end

end
