require 'rubygems'
require 'active_record'

class Admin::AdminsController < Admin::AdminController#ApplicationController
  layout 'admin'
  before_filter :require_user

  def index
	@admins = Doctor.find_by_sql("SELECT * FROM doctors WHERE user_type = 'Admin' ORDER BY last_name, first_name, email")
 
  end

  def show
	@admin = Doctor.find_by_sql("SELECT * FROM doctors WHERE id = " + params[:id])
	@admin = @admin[0]
	#render(:layout =>  'blank')
  end

  def update
	@admin = Doctor.find_by_sql("SELECT * FROM doctors WHERE id = " + params[:id])
	@admin = @admin[0]
	@error = ""
	@admin.first_name = params[:first_name]
	@admin.last_name = params[:last_name]
	if params[:email].match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
		@admin.email = params[:email]
	else
		@error += "Please enter a valid email.<br/>"
	end
	if params[:password] != nil && params[:password] != ""
		if params[:password] == "" || !params[:password].index(/[0-9]/) || !params[:password].index(/[a-z]/) || params[:password].size < 6
			@error += "Please enter a valid password. The password must be 6 characters or more in length and contain both letters and numbers.<br/>"
		elsif params[:password] == params[:password_conf]
			@admin.password = params[:password]
		else
			@error += "Password confirmation does not match.<br/>"
		end
	end
	@admin.save(false)
	if @error == ""
		redirect_to "/admin/admins"
	else
		session[:error] = @error
		redirect_to "/admin/admins/"+params[:id]
	end
  end

  def confirm_delete
	@admin = Doctor.find_by_sql("SELECT * FROM doctors WHERE id = " + params[:id])
	@admin = @admin[0]
  end

  def delete_admin
	ActiveRecord::Base.connection.execute("DELETE FROM doctors WHERE id = "+params[:id])
	redirect_to "/admin/admins"
	#render(:layout =>  'blank')
  end

  def new_admin
	@admin = Doctor.new()
  end

  def save_admin
	@error = ""
	if !params[:admin][:email].match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
		@error += "Please enter a valid email.<br/>"
	else
		check_duplicate_email = Doctor.find_by_sql("SELECT COUNT(*) as count FROM doctors WHERE email = '" + params[:admin][:email] + "'")
		if check_duplicate_email[0].count != "0"
			@error += "The email address you entered has been registered with another HealthyPrice account.<br/>"
		end
	end
	if params[:admin][:password] == "" || !params[:admin][:password].index(/[0-9]/) || !params[:admin][:password].index(/[a-z]/) || params[:admin][:password].size < 6
		@error += "Please enter a valid password. The password must be 6 characters or more in length and contain both letters and numbers.<br/>"
	elsif params[:admin][:password] != params[:password_confirm]
		@error += "Password confirmation does not match.<br/>"
	end
	@new_admin = Doctor.new(params[:admin])
	@new_admin.single_access_token = Authlogic::Random.friendly_token
	@new_admin.user_type = "Admin"
	if @error == ""
		@new_admin.save(false)
		redirect_to "/admin/admins"
	else
		session[:error] = @error
		session[:admin_data] = @new_admin
		redirect_to "/admin/admins/new_admin"
	end
  end

end