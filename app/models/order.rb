class Order < ActiveRecord::Base
  belongs_to :doctor_service
  # Added by Vishva begins
  belongs_to :specialty_service
  belongs_to :doctor
  # Added by Vishva ends
 
  ORDER_NUMBER_FORMAT = '####AAAA'
  BILLING_CODE_FORMAT = 'AAAA'	#'######AAAA' #'AAAA-AAAA-####'
  PIN_FORMAT = '####'
  
  validates_acceptance_of :terms_and_conditions
=begin
  validate :patient_name
  validate :first_name
  validate :last_name
  validate :address
  validate :city
  validate :state
  validate :zipcode
  #validate :phone
  #validate :doctor_service_id
  validate :phone, :with => /^([\d][^\d]*){10,}/, :message => 'must have at least 10 digits'
  validate :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'is invalid'
  validate :credit_card
  validate :ccv
  validate :expiration
  validates_acceptance_of :terms_and_conditions

def patient_name
	errors.add_to_base("Patient name can't be blank")
end
def first_name
	errors.add_to_base("First name can't be blank") 
end
def last_name
	errors.add_to_base("Last name can't be blank") 
end
def address
	errors.add_to_base("Address can't be blank") 
end
def city
	errors.add_to_base("City can't be blank") 
end
def state
	errors.add_to_base("State can't be blank") 
end
def zipcode
	errors.add_to_base("Zip code can't be blank") 
end
#def phone
#	errors.add_to_base("Phone number can't be blank") 
#end
def email
	errors.add_to_base("Email address can't be blank") 
end
def credit_card
	errors.add_to_base("Credit card number can't be blank") 
end
def ccv
	errors.add_to_base("CCV can't be blank") 
end
#def expiration
#	errors.add_to_base("Expiration date can't be blank") 
#end
def phone
	errors.add_to_base("Phone can't be blank") 
end
def terms_and_conditions
	errors.add_to_base("Terms and conditions must be accepted") 
end
=end

  def name
    [self.first_name, self.last_name].join(" ")
  end

  def address2lines
    @output = ""
    @output = self.address + ","						if self.address != nil && self.address != ""
    @output = @output + " " + self.address2 + ","		if self.address2 != nil && self.address2 != ""
    @output = @output + "<br/>" + self.city + ", " + self.state_code + " " + self.zipcode
  end

  def state_code
	if self.state == 'Alabama'
		'AL'
	elsif self.state == 'Alaska'
		'AK'
	elsif self.state == 'America Samoa'
		'AS'
	elsif self.state == 'Arizona'
		'AZ'
	elsif self.state == 'Arkansas'
		'AR'
	elsif self.state == 'California'
		'CA'
	elsif self.state == 'Colorado'
		'CO'
	elsif self.state == 'Connecticut'
		'CT'
	elsif self.state == 'Delaware'
		'DE'
	elsif self.state == 'District of Columbia'
		'DC'
	elsif self.state == 'Micronesia1'
		'FM'
	elsif self.state == 'Florida'
		'FL'
	elsif self.state == 'Georgia'
		'GA'
	elsif self.state == 'Guam'
		'GU'
	elsif self.state == 'Hawaii'
		'HI'
	elsif self.state == 'Idaho'
		'ID'
	elsif self.state == 'Illinois'
		'IL'
	elsif self.state == 'Indiana'
		'IN'
	elsif self.state == 'Iowa'
		'IA'
	elsif self.state == 'Kansas'
		'KS'
	elsif self.state == 'Kentucky'
		'KY'
	elsif self.state == 'Louisiana'
		'LA'
	elsif self.state == 'Maine'
		'ME'
	elsif self.state == 'Islands1'
		'MH'
	elsif self.state == 'Maryland'
		'MD'
	elsif self.state == 'Massachusetts'
		'MA'
	elsif self.state == 'Michigan'
		'MI'
	elsif self.state == 'Minnesota'
		'MN'
	elsif self.state == 'Mississippi'
		'MS'
	elsif self.state == 'Missouri'
		'MO'
	elsif self.state == 'Montana'
		'MT'
	elsif self.state == 'Nebraska'
		'NE'
	elsif self.state == 'Nevada'
		'NV'
	elsif self.state == 'New Hampshire'
		'NH'
	elsif self.state == 'New Jersey'
		'NJ'
	elsif self.state == 'New Mexico'
		'NM'
	elsif self.state == 'New York'
		'NY'
	elsif self.state == 'North Carolina'
		'NC'
	elsif self.state == 'North Dakota'
		'ND'
	elsif self.state == 'Ohio'
		'OH'
	elsif self.state == 'Oklahoma'
		'OK'
	elsif self.state == 'Oregon'
		'OR'
	elsif self.state == 'Palau'
		'PW'
	elsif self.state == 'Pennsylvania'
		'PA'
	elsif self.state == 'Puerto Rico'
		'PR'
	elsif self.state == 'Rhode Island'
		'RI'
	elsif self.state == 'South Carolina'
		'SC'
	elsif self.state == 'South Dakota'
		'SD'
	elsif self.state == 'Tennessee'
		'TN'
	elsif self.state == 'Texas'
		'TX'
	elsif self.state == 'Utah'
		'UT'
	elsif self.state == 'Vermont'
		'VT'
	elsif self.state == 'Virgin Island'
		'VI'
	elsif self.state == 'Virginia'
		'VA'
	elsif self.state == 'Washington'
		'WA'
	elsif self.state == 'West Virginia'
		'WV'
	elsif self.state == 'Wisconsin'
		'WI'
	elsif self.state == 'Wyoming'
		'WY'
	end
  end

  def pay_ref_id
    if doctor_payments_id == -1
	    ""
    else
	    doctor_payments_id.inspect
    end
  end

  def str_date
    self.created_at.strftime("%m/%d/%Y")
  end

  def provider
    if self.doctor_service == nil
	    ""
    else
	    doctor = self.doctor_service.doctor
	    if doctor == nil
		""
	    else
		[doctor.first_name, doctor.last_name].join(" ") + " (" + doctor.id.inspect + ")"
	    end
    end
  end

   def procedure
    if self.doctor_service == nil
	    ""
    else
	    doctor = self.doctor_service.specialty_service
	    [doctor.service_name]
    end
  end

    def pracarea
    doctor = self.specialty_service.specialty
    if doctor == nil
	    "-Not Found-"
    else
	    [doctor.name]
    end
  end
  
  def submit!
    self.assign_number!
    self.assign_billing_code!
    self.assign_pin!
    self.submitted = 1 #true
    self.save
  end
  
  def assign_number!
    self.number = find_unique_random('number',ORDER_NUMBER_FORMAT)
  end
  
  def assign_billing_code!
    self.billing_code = (self.id-10000000+100000).inspect + find_unique_random('billing_code',BILLING_CODE_FORMAT)
  end

  def assign_pin!
    self.pin = Util.formatted_random_string(PIN_FORMAT)
  end
  
  def find_unique_random(field_name,pattern)
    generated_pattern = Util::formatted_random_string(pattern)
    collision = Order.find(:all, :conditions => {field_name => generated_pattern})
    while collision.length > 0 do
      generated_pattern = Util::formatted_random_string(pattern)
    end
    generated_pattern
  end
 


end
