class HomeController < ApplicationController

  FAMILY_SPECIALTY_NAME = "Family & General Practice"

  def index
    #services box
    popular_specialty_services_csv = get_config("popular_specialty_services_csv")
    popular_specialty_services_csv = popular_specialty_services_csv.split(",")
    qstr_part = ""
=begin
    popular_specialty_services_csv.each do |ssid|
	if qstr_part == ""
		qstr_part += "specialty_services.id = " + ssid
	else
		qstr_part += " OR specialty_services.id = " + ssid
	end
    end
    @specialty_services_popular = SpecialtyService.find(:all,
      :limit => 6, 
      :include => [:specialty,:service], 
      :conditions => qstr_part)
=end
    @specialty_services_popular = Array.new
    popular_specialty_services_csv.each do |ssid|
	tmp_res = SpecialtyService.find_by_sql("SELECT specialty_services.id, service_name, specialties.name AS specialty_name, customer_price " +
		"FROM specialty_services, specialties " +
		"WHERE specialty_services.specialty_id = specialties.id" +
		" AND specialty_services.id = " + ssid)
	if tmp_res.size != 0
		@specialty_services_popular << tmp_res[0]
	end
    end

=begin
    @specialty_services_popular = SpecialtyService.find(:all,
      :limit => 7, 
      :include => [:specialty,:service], 
      :conditions => {'specialties.name' => FAMILY_SPECIALTY_NAME},
      :order => SpecialtyService.specialty_case_order_sql)

    @specialty_services_family = SpecialtyService.find(:all,
      :limit => 4, 
      :include => [:specialty,:service], 
      :conditions => {'specialties.name' => FAMILY_SPECIALTY_NAME},
      :order => SpecialtyService.specialty_case_order_sql)
    
    @specialty_services_not_family = SpecialtyService.find(:all, 
      :include => [:specialty,:service], 
      :limit => 4, 
      :order => 'rand()', 
      :conditions => ['specialties.name != ?',FAMILY_SPECIALTY_NAME])
=end

    @specialty_services = homepage_specialty_services


    @total_services = SpecialtyService.count
    @min_price = SpecialtyService.minimum(:doctor_price)
    @max_price = SpecialtyService.maximum(:doctor_price)
    
    #specialties box
    @specialties = Specialty.find(:all, :limit => 12, :order => 'rand()');
    @total_specialties = Specialty.count
  end

  def get_config(key)
	config = Specialty.find_by_sql("SELECT config_value FROM configurations WHERE config_name = '"+key+"'")
	if config.size == 0
		"Not Found"
	else
		config[0].config_value
	end
  end

  def subscribe
	sql = "INSERT INTO subscribers(full_name, email, created_at) VALUES('"+params[:textfield2]+"', '"+params[:textfield3]+"', NOW())"
	ActiveRecord::Base.connection.execute(sql)
  end

  def contactform
	#
  end

  def providerapp
	redirect_to "/doctor_section/signup/step1"
  end
  def captchavalid
	if verify_recaptcha(params)
	  render :text => 'verify' and return false
	else
	  render :text => 'notverify' and return false
	end
	  
  end

  def contactsubmit
	@result = Emailer.deliver_web_contact_form(params[:first_name], params[:last_name], params[:email], params[:phone], params[:category], params[:subject], params[:inquiry])
  end

  def homepage_specialty_services
  end

  def file_not_found
  end

end