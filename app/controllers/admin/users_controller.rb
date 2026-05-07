class Admin::UsersController < ApplicationController
  before_action :require_approval_permission

  def index
    @users = User.order(created_at: :desc)
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User '#{@user.email_address}' status updated."
    else
      redirect_to admin_users_path, alert: "Failed to update user status."
    end
  end

  private

  def user_params
    params.require(:user).permit(:approved)
  end

  def require_approval_permission
    unless Current.user&.master?
      redirect_to root_path, alert: "Only master users can access the Staff Management area."
    end
  end
end
