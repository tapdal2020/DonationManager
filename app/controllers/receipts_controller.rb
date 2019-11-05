class ReceiptsController < ApplicationController
    before_action :authenticate_user!, except: [:new, :create]

    def show
    end

end
