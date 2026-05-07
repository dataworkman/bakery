class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    
    if @user.save
      if @user.approved?
        redirect_to new_session_path, notice: "Account created and automatically approved (First Admin)! Please log in."
      else
        redirect_to new_session_path, notice: "Account created successfully! Please wait for an admin to approve your account before logging in."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
