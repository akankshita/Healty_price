  #require 'rubygems'
#require 'active_merchant'
require 'date'

class OrdersController < ApplicationController
include SslRequirement

  before_filter :check_for_order, :only => [:details, :submit, :thank_you]

#if you are using in local server you neeed to comment it
   def ssl_required?
    if get_config("SSL") == "true"
      true
    else
      false
    end
  end

  def new
    tmp = DoctorService.find_by_sql("SELECT COUNT(*) AS Count FROM doctor_services WHERE id = '" + params[:doctor_service_id] + "'")
    if tmp[0].Count == "0"
      @Error = "Not Found"
      render :action => 'notavailable'
    else
      @doctor_service = DoctorService.find(params[:doctor_service_id])
       session[:doctor_service] = @doctor_service
      @order = Order.new() 
      session[:order] = @order
    end
  end

  def create
    @doctor_service = session[:doctor_service]
      unless params[:order][:promotional].blank?
        @tokan = Tokan.find_by_service_id_and_tokan_name(@doctor_service.specialty_service_id, params[:order][:promotional])
        session[:tokan] = @tokan
        session[:test] = ""
        session[:dis] = @tokan
      else
        session[:test] = "no value"
        
      end
    
    @order = session[:order]
    doctor_service_id = params[:doctor_service_id]
     #===========================================================================
    doctor_service_data = Order.find_by_sql("SELECT doctor_id, specialty_service_id FROM doctor_services WHERE id = " + doctor_service_id)[0]
    @doctor_service = DoctorService.find(params[:doctor_service_id])
    @order.doctor_service_id = doctor_service_id
    @order.specialty_service_id = doctor_service_data.specialty_service_id
    @order.doctor_id = doctor_service_data.doctor_id
    @order.doctor_price = @doctor_service.specialty_service.doctor_price
    #@order.customer_price = @doctor_service.specialty_service.customer_price
    
    #===========================================================================
     @Error = ""    #Validate Begin
    @order.patient_name = params[:order][:patient_name]
    if params[:order][:patient_name] == ""
      @Error += "Please enter the patient name.<br/>"
    end
    @order.first_name = params[:order][:first_name]
    if params[:order][:first_name] == ""
      @Error += "Please enter your first name.<br/>"
    end
    @order.last_name = params[:order][:last_name]
    if params[:order][:last_name] == ""
      @Error += "Please enter your last name.<br/>"
    end
    @order.address = params[:order][:address]
    @order.address2 = params[:order][:address2]
    if params[:order][:address] == ""
      @Error += "Please enter the street address.<br/>"
    end
    @order.city = params[:order][:city]
    if params[:order][:city] == ""
      @Error += "Please enter the city.<br/>"
    end
    @order.state = params[:order][:state]
    if params[:order][:state] == ""
      @Error += "Please select a state.<br/>"
    end
    @order.zipcode = params[:order][:zipcode]
    if params[:order][:zipcode] == ""
      @Error += "Please enter the zip code.<br/>"
    end
    @order.phone = params[:order][:phone]
    if params[:order][:phone] == ""
      @Error += "Please enter your phone number.<br/>"
    elsif !params[:order][:phone].match(/^([\d][^\d]*){10,}/)
      @Error += "Please enter a valid Phone number. It must have at least 10 digits.<br/>"
    end
    @order.email = params[:order][:email]
    if params[:order][:email] == ""
      @Error += "Please enter your email address.<br/>"
    elsif !params[:order][:email].match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
      @Error += "Please enter a valid email address.<br/>"
    end
    #@order.cctype = CardType(params[:order][:credit_card])
    if params[:pay_cc] == "new_cc" && params[:order][:placed_by] == "Admin"
      if params[:order][:credit_card] == ""
        session[:order_credit_card_override] = nil
      else
        session[:order_credit_card_override] = params[:order][:credit_card]
      end
      if params[:order][:ccv] == ""
        session[:order_cvv_override] = nil
      else
        session[:order_cvv_override] = params[:order][:ccv]
      end
    end
    session[:pay_cc] = params[:pay_cc]
    if session[:order_credit_card_override] != nil && params[:order][:credit_card].match(/^XXXX/)
      @order.credit_card = session[:order_credit_card_override]
    else
      @order.credit_card = params[:order][:credit_card]
    end
    @order.placed_by = params[:order][:placed_by]
    if !validate_credit_card(@order.credit_card) || @order.credit_card == ""
      @Error += "Please enter a valid credit card number.<br/>"
    end
    if session[:order_cvv_override] != nil && params[:order][:ccv] == "XXX"
      @order.ccv = session[:order_cvv_override]
    else
      @order.ccv = params[:order][:ccv]
    end
    if @order.ccv == ""
      @Error += "Please enter the card security code (CVV, CVC, or CSC).<br/>"
    end
    if params[:order][:expiration_year] == "" || params[:order][:expiration_month] == ""
      @Error += "Please enter the credit card expiration year/month.<br/>"
      @month = 0
      @year = 0
    else
      @month = params[:order][:expiration_month].to_i
      @year = params[:order][:expiration_year].to_i
      @order.expiration = Date.new(y = @year, m = @month, d = 3)
      if @year < Time.now.year || (@year == Time.now.year && @month < Time.now.month)
        @Error += "The credit card expiration month you have selected is in the past. Please correct the expiration date or enter a different credit card.<br/>"
      end
    end
    #@Error += @year.inspect + ":" + @month.inspect + ":" + @order.expiration.inspect + "<br/>"
    if params[:order][:terms_and_conditions] != "1"
      @Error += "Please check the box to accept the HealthyPrice terms and conditions.<br/>"
    end
    if !verify_recaptcha
      @Error += "Your captcha is incorrect. Please try again.<br/>"
    end
    @order.market_survey = params[:order][:market_survey]
    if @Error == ""
      redirect_to details_orders_path()
     else
      @doctor_service = DoctorService.find(doctor_service_id)
      render :action => :new
     end
   end

=begin
  # check specified conditions to determine the type of card
  def CardType(number)
  if number =~ /^3/
    "AMEX"
  elsif number =~ /^4/
    "Visa"
  elsif number =~ /^5/
    "MasterCard"
  elsif number =~ /^6/
    "Discover"
  else
    ""
  end
  end
=end
   def details
    @price_change = discount if   session[:dis]
    redirect_to thank_you_orders_path() if @order.submitted == 1
  end

  def submit
    @order = session[:order]
    session[:order_credit_card_override] = nil
    session[:order_cvv_override] = nil
     @price_change = discount
#=begin
    ActiveMerchant::Billing::Base.mode = :live
    
    unless @price_change     
      amount = @order.doctor_service.specialty_service.customer_price*100
    else
      amount = @price_change*100
    end
            
    @order.customer_price = amount/100
    @month = @order.expiration.month
    @year = @order.expiration.year
    credit_card = ActiveMerchant::Billing::CreditCard.new(
                  :first_name         => @order.first_name,
                  :last_name          => @order.last_name,
                  :number             => @order.credit_card,
                  :month              => @month,
                  :year               => @year,
                  :verification_value => @order.ccv)
    gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(
              :login => '4uA2N5NvUsHV',
              :password => '483mwLN9Sztf22eb',
              :test =>false)
=begin
    gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(
              :login => '7NJnb834xP',
              :password => '9c675QvLE6kzs9dc',
              :test => false)
=end
    if credit_card.valid?
      #response = gateway.authorize(amount, credit_card)
      order_id = OrderId.new()  #Order.find_by_sql("SELECT MAX(id) AS max_id FROM order_ids")
      order_id.save # = order_id[0].max_id.to_i + 1
      inv_options = {:order_id => order_id.id.inspect}
      response = gateway.purchase(amount, credit_card, inv_options)
      if response.success?
          #@order.cctype = credit_card.type
        @order.id = order_id.id
        @order.credit_card = encrypt(@order.credit_card)
        @order.ccv = encrypt(@order.ccv.inspect)
        @order.save
        @order.submit! unless @order.submitted == 1
        session[:order_number] = @order.number
        session[:dis] = nil
        redirect_to thank_you_orders_path()
      else
          @Error = "The transaction was refused by your card issuer.<br/>"+response.message.inspect
          render :action => :details
      end
    else
       @Error = "Your credit card number is invalid!<br/>"
       render :action => :details
   end
  end

  def lookup
  end

  def perform_lookup
    billing_code = params[:billing_code].gsub("#", "")
    @SQL = "SELECT * FROM orders WHERE billing_code = '"+billing_code+"' AND pin = '"+params[:pin]+"'"
    order = Order.find_by_sql(@SQL)
    if order.size == 0
      @error = "Invalid billing code or PIN!"
      @order = nil
      render :action => :lookup
    else
      @order = Order.find_by_id(order[0].id)
    end
  end

  def admin_order_details_ajax
    if params[:id] == nil
      @error = "Invalid order ID!"
    else
      @SQL = "SELECT * FROM orders WHERE id = '" + params[:id] + "'"
      order = Order.find_by_sql(@SQL)
      if order.size == 0
    @error = "Invalid order ID!"
    @order = nil
      else
    @order = order[0]
    @order.credit_card = decrypt(@order.credit_card)
    @ccnum = @order.credit_card
    session[:order_credit_card_override] = @order.credit_card
    @order.ccv = decrypt(@order.ccv)
    session[:order_cvv_override] = @order.ccv
      end
    end
    render :layout => "blank"
  end

  def cancel_order
    if params[:order_id] != nil
  ActiveRecord::Base.connection.execute("UPDATE orders SET orderstatus = 'Cancelled' WHERE id = "+params[:order_id])
  @order = Order.find_by_id(params[:order_id])
  @doctor = @order.doctor_service.doctor
  Emailer.deliver_order_cancel_customer(@order.email, @order.name, @order.id.inspect, @order.billing_code, @order.pin)
  Emailer.deliver_order_cancel_provider(@doctor.notification_email, @doctor.name, @order.id.inspect, @order.name, @order.doctor_service.specialty_service.service_name+" ("+@order.doctor_service.specialty_service.specialty.name+")")
    end
    render :action => :perform_lookup
  end

  def notavailable
  end

  def validate_credit_card(number)
    reverse_card_num = number.reverse
    sum = 0
    reverse_card_num.scan(/./).each_with_index do |digit, index|
      digit = digit.to_i
      digit *= 2 if index % 2 != 0
      if digit.to_s.length == 2
        first_num = digit.to_s[0..0]
        second_num = digit.to_s[1..1]
        digit = first_num.to_i + second_num.to_i
      end
      sum += digit
    end
    pass = sum % 10 == 0 ? true : false
  end

  def edit
  @order = session[:order]
  @doctor_service = DoctorService.find(@order.doctor_service_id)
  render :action => :new
  end

  def update
    @order = session[:order]
    @Error = ""    #Validate Begin
    @order.patient_name = params[:order][:patient_name]
    if params[:order][:patient_name] == ""
      @Error += "Please enter the patient name.<br/>"
    end
    @order.first_name = params[:order][:first_name]
    if params[:order][:first_name] == ""
      @Error += "Please enter your first name.<br/>"
    end
    @order.last_name = params[:order][:last_name]
    if params[:order][:last_name] == ""
      @Error += "Please enter your last name.<br/>"
    end
    @order.address = params[:order][:address]
    @order.address2 = params[:order][:address2]
    if params[:order][:address] == ""
      @Error += "Please enter the street address.<br/>"
    end
    @order.city = params[:order][:city]
    if params[:order][:city] == ""
      @Error += "Please enter the city.<br/>"
    end
    @order.state = params[:order][:state]
    if params[:order][:state] == ""
      @Error += "Please select a state.<br/>"
    end
    @order.zipcode = params[:order][:zipcode]
    if params[:order][:zipcode] == ""
      @Error += "Please enter the zip code.<br/>"
    end
    @order.phone = params[:order][:phone]
    if params[:order][:phone] == ""
      @Error += "Please enter your phone number.<br/>"
    elsif !params[:order][:phone].match(/^([\d][^\d]*){10,}/)
      @Error += "Please enter a valid Phone number. It must have at least 10 digits.<br/>"
    end
    @order.email = params[:order][:email]
    if params[:order][:email] == ""
      @Error += "Please enter your email address.<br/>"
    elsif !params[:order][:email].match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
      @Error += "Please enter a valid email address.<br/>"
    end
    if params[:pay_cc] == "new_cc" && params[:order][:placed_by] == "Admin"
  if params[:order][:credit_card] == ""
    session[:order_credit_card_override] = nil
  else
    session[:order_credit_card_override] = params[:order][:credit_card]
  end
  if params[:order][:ccv] == ""
    session[:order_cvv_override] = nil
  else
    session[:order_cvv_override] = params[:order][:ccv]
  end
    end
    session[:pay_cc] = params[:pay_cc]
    if session[:order_credit_card_override] != nil && params[:order][:credit_card].match(/^XXXX/)
      @order.credit_card = session[:order_credit_card_override]
    else
      @order.credit_card = params[:order][:credit_card]
    end
    @order.placed_by = params[:order][:placed_by]
    if !validate_credit_card(@order.credit_card) || @order.credit_card == ""
      @Error += "Please enter a valid credit card number.<br/>"
    end
    if session[:order_cvv_override] != nil && params[:order][:ccv] == "XXX"
      @order.ccv = session[:order_cvv_override]
    else
      @order.ccv = params[:order][:ccv]
    end
    if @order.ccv == ""
      @Error += "Please enter the card security code (CVV, CVC, or CSC).<br/>"
    end
    if params[:order][:expiration_year] == "" || params[:order][:expiration_month] == ""
  @Error += "Please enter the credit card expiration year/month.<br/>"
  @month = 0
  @year = 0
    else
  @month = params[:order][:expiration_month].to_i
  @year = params[:order][:expiration_year].to_i
  @order.expiration = Date.new(y = @year, m = @month, d = 3)
  if @year < Time.now.year || (@year == Time.now.year && @month < Time.now.month)
    @Error += "The credit card expiration month you have selected is in the past. Please correct the expiration date or enter a different credit card.<br/>"
  end
    end
    if params[:order][:terms_and_conditions] != "1"
      @Error += "Please check the box to accept the HealthyPrice terms and conditions.<br/>"
    end
    @order.market_survey = params[:order][:market_survey]
    #Validate End
    if @Error == ""
  session[:order_number] = @order.number
  render :action => :details
    else
  @doctor_service = DoctorService.find(params[:id])
  render :action => :new
    end
  end
  
  def thank_you
    #Send the Email
    if current_user_session != nil && current_user.user_type == "Admin"
       ActionController::Base.new.expire_fragment("new_order_customer_addon")
       ActionController::Base.new.expire_fragment("new_order_provider_addon")
       ActionController::Base.new.expire_fragment("new_order_admin_addon")
       #recipient, full_name, order_number, billing_code
       Emailer.deliver_new_order_customer_addon(@order.email, @order.name, @order.id.inspect, @order.billing_code, @order.pin, @order.doctor_service.doctor, @order)
       #recipient, full_name, order_number, patient_name, procedure
       Emailer.deliver_new_order_provider_addon(@order.doctor_service.doctor.notification_email, @order.doctor_service.doctor.name, @order.id.inspect, @order.patient_name, @order.doctor_service.specialty_service.service_name+" ("+@order.doctor_service.specialty_service.specialty.name+")", @order)
       #recipient, full_name, order_number, patient_name, procedure
       Emailer.deliver_new_order_admin_addon(get_config("admin_email"), @order.doctor_service.doctor.name, @order.id.inspect, @order.patient_name, @order.doctor_service.specialty_service.service_name+" ("+@order.doctor_service.specialty_service.specialty.name+")", @order, @order.doctor_service.doctor)
     else
       ActionController::Base.new.expire_fragment("new_order_customer")
       ActionController::Base.new.expire_fragment("new_order_provider")
       ActionController::Base.new.expire_fragment("new_order_admin")
       #recipient, full_name, order_number, billing_code
       Emailer.deliver_new_order_customer(@order.email, @order.name, @order.id.inspect, @order.billing_code, @order.pin, @order.doctor_service.doctor, @order)
       #recipient, full_name, order_number, patient_name, procedure
       Emailer.deliver_new_order_provider(@order.doctor_service.doctor.notification_email, @order.doctor_service.doctor.name, @order.id.inspect, @order.patient_name, @order.doctor_service.specialty_service.service_name+" ("+@order.doctor_service.specialty_service.specialty.name+")", @order)
       #recipient, full_name, order_number, patient_name, procedure
       Emailer.deliver_new_order_admin(get_config("admin_email"), @order.doctor_service.doctor.name, @order.id.inspect, @order.patient_name, @order.doctor_service.specialty_service.service_name+" ("+@order.doctor_service.specialty_service.specialty.name+")", @order, @order.doctor_service.doctor)
     end
    #@admin_email = get_config("admin_email")
    #render :action => :details
  end

  def error
  end

  def encrypt(input)
  input = input.gsub("-", "").gsub(".", "").to_i
  input = (input * 2) + 3
  input.inspect
  end

  def decrypt(input)
  input = input.to_i
  input = (input - 3) / 2
  input = input.inspect
  if input.length == 1
    "00"+input
  elsif input.length == 2
    "0"+input
  else
    input
  end
  end

  def isNumeric(s)
  begin
    Float(s)
  rescue
    false # not numeric
  else
    true # numeric
  end
  end

private
  def check_for_order
    @order = session[:order]
    #if session[:order_id].nil?
      #redirect_to error_orders_path()
    #else
      #@order = Order.find(session[:order_id])  
    #end
  end
  
end
 def discount
   if session[:dis]
     @doctor_service = session[:doctor_service]
     @tokan = session[:tokan]
     start_date = @tokan.date_from.yday 
     end_date = @tokan.date_to.yday
     today_date = Date.today.yday
     
       if (start_date <= today_date) and (end_date >= today_date)
         todays_offer = true
       else 
         todays_offer = false
       end
      
       if todays_offer == true
         price_change = (@doctor_service.specialty_service.customer_price/100)* @tokan.discount
         @price_change = @doctor_service.specialty_service.customer_price - price_change
       else
          @price_change = nil
    
       end
        
     end
  end

  