# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def permitted_keys
    [:first_name, :last_name, :street_address_line_1, :street_address_line_2, :city, :state, :zip_code]
  end

  def configure_sign_in_params
      devise_parameter_sanitizer.permit(:sign_in, keys: permitted_keys)
  end
end
