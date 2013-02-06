ActionController::Routing::Routes.draw do |map|
  map.resources :line_items

  map.resources :carts

  map.resources :carts

  map.resources :line_items

  map.resources :carts

  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  map.resources     :tokan, :only => [:edit, :update,:create,:delete]
  map.tokan_pramotional'admin/tokan/promotional', :action => 'promotional', :controller => 'tokan'
  map.tokan_create '/tokan/create', :controller => 'tokan', :action => 'create'
  map.tokan_promotional 'tokan/promotional/:id',:controller => 'tokan',:action => 'delete'
 
  map.resources     :orders, 
    :only => [:edit, :update], 
    :collection => { :details => :get, :error => :get, :thank_you => :get, :submit => :put, :cancel => :put, :lookup => :get }
  map.order_edit '/orders/edit', :controller => 'orders', :action => 'edit'
  map.order_edit '/orders/create', :controller => 'orders', :action => 'create'
  map.lookup_action '/orders/lookup', :controller => 'orders', :action => 'perform_lookup', :conditions => {:method => :post}
  map.lookup_action '/orderlookup', :controller => 'orders', :action => 'lookup'
  map.lookup_action '/orders/cancel_order', :controller => 'orders', :action => 'cancel_order', :conditions => {:method => :post}
  map.order_new     '/orders/new/:doctor_service_id', :controller => 'orders', :action => 'new'
  map.order_submit    '/orders/submit', :controller => 'orders', :action => 'submit'
  map.order_create  '/orders/:doctor_service_id', :controller => 'orders', :action => 'create', :conditions => { :method => :post }
  map.admin_order_details    '/orders/retrive_details/:id', :controller => 'orders', :action => 'admin_order_details_ajax'


  map.path 'admin/admins/confirm_delete/:id', :controller => 'admin/admins', :action => 'confirm_delete'
  map.path 'admin/admins/delete', :controller => 'admin/admins', :action => 'delete_admin'
  map.path 'admin/admins/update', :controller => 'admin/admins', :action => 'update'
  map.path 'admin/admins/new_admin', :controller => 'admin/admins', :action => 'new_admin'
  map.path 'admin/admins/save_admin', :controller => 'admin/admins', :action => 'save_admin'
  map.path 'admin/doctors_nest/:id', :controller => 'admin/doctors_nest', :action => 'index', :conditions => { :method => :get }
  map.path 'admin/doctors_n/:id', :controller => 'admin/doctors_nest', :action => 'doctors', :conditions => { :method => :get }
  map.path 'admin/doctors_for_service/:id/:spc_id', :controller => 'admin/doctors_nest', :action => 'doctors_fs', :conditions => { :method => :get }
  map.path 'admin/doctors/delete_doctor/:id', :controller => 'admin/doctors', :action => 'delete_doctor', :conditions => { :method => :get }

  map.path 'admin/specialties/enable_specialty_for_doctor', :controller => 'admin/specialties', :action => 'enable_specialty_for_doctor'
  map.path 'admin/specialties/disable_for_provider/:doc_id/:spec_id/:row_id', :controller => 'admin/specialties', :action => 'disable_for_provider'

  map.path 'admin/specialty_services/add_service', :controller => 'admin/doctors_nest', :action => 'add_service'
  map.path 'admin/specialty_services/enable_for_provider', :controller => 'admin/specialty_services', :action => 'enable_for_provider'
  #^-^ /:doc_id/:spc_srv_id
  map.path 'admin/specialty_services/disable_for_provider/:doc_id/:spc_srv_id/:spc_id', :controller => 'admin/specialty_services', :action => 'disable_for_provider'
  map.path 'admin/specialty_services/:id', :controller => 'admin/doctors_nest', :action => 'specialty_services', :conditions => { :method => :get }
  map.path 'admin/specialty_services_doc/:id/:doc_id', :controller => 'admin/doctors_nest', :action => 'specialty_services_doc', :conditions => { :method => :get }

  map.namespace(:admin) do |admin|
    admin.resources :orders, :active_scaffold => true
    admin.resources :configurations, :active_scaffold => true
    #admin.resources :doctor_payments, :active_scaffold => true
    admin.resources :services, :active_scaffold => true 
    admin.resources :pages, :active_scaffold => true 
    admin.resources :specialties, :active_scaffold => true 
    admin.resources :specialty_services, :active_scaffold => true 
    admin.resources :doctors, :active_scaffold => true 
    #admin.resources :doctors_nest, :active_scaffold => true 
    admin.resources :doctor_services, :active_scaffold => true 
    admin.resources :admins, :active_scaffold => true 
    admin.resources :notes, :active_scaffold => true 
    admin.root :controller => 'admin', :action => 'index'
  end
  map.admin 'admin/doctors/edit_details/:id', :controller => 'admin/doctor_payments', :action => 'details', :conditions => { :method => :get }
  #map.admin 'admin/doctor_payments/details/:id', :controller => 'admin/doctor_payments', :action => 'details', :conditions => { :method => :get }
  map.admin 'admin/doctor_payments/details_update/:id', :controller => 'admin/doctor_payments', :action => 'details_update', :conditions => { :method => :post }
  map.admin 'admin/doctor_payments/add_orders/:id', :controller => 'admin/doctor_payments', :action => 'add_orders', :conditions => { :method => :post }
  map.admin 'admin/doctor_payments/remove_payments/:id', :controller => 'admin/doctor_payments', :action => 'remove_payments', :conditions => { :method => :get }
  map.admin 'admin/doctor_payments/new_payment', :controller => 'admin/doctor_payments', :action => 'new_payment', :conditions => { :method => :get }
  map.admin 'admin/doctor_payments/pending_orders', :controller => 'admin/doctor_payments', :action => 'pending_orders', :conditions => { :method => :post }
  map.admin 'admin/doctor_payments/add_payments', :controller => 'admin/doctor_payments', :action => 'add_payments', :conditions => { :method => :post }
  #map.admin 'admin/doctor_payments/search', :controller => 'admin/doctor_payments', :action => 'search'
  map.admin 'admin/doctor_payments/search', :controller => 'admin/doctor_payments', :action => 'search', :conditions => { :method => :post }
  map.admin 'admin/doctor_payments/show_one_order/:id', :controller => 'admin/doctor_payments', :action => 'show_one_order', :conditions => { :method => :get }
  map.admin 'admin/orders/bydoctor/:docid', :controller => 'admin/doctor_orders', :action => 'index', :conditions => { :method => :get }
  map.admin 'admin/orders/context/:context', :controller => 'admin/orders', :action => 'index', :conditions => { :method => :get }
  map.admin 'admin/sql', :controller => 'admin/sql', :action => 'index'
  map.admin 'admin/doctor_payments', :controller => 'admin/doctor_payments', :action => 'payments', :conditions => { :method => :get }
  map.admin 'admin/payments_show', :controller => 'admin/doctor_payments', :action => 'show_details', :conditions => { :method => :get }
  map.admin 'admin/payments_edit', :controller => 'admin/doctor_payments', :action => 'edit_details', :conditions => { :method => :get }
  map.admin 'admin/payments_update', :controller => 'admin/doctor_payments', :action => 'update_details', :conditions => { :method => :post }
  map.admin 'admin/payments_updateupdate_doctor_details/:id', :controller => 'admin/doctor_payments', :action => 'update_doctor_details', :conditions => { :method => :post }
  map.path 'admin/cron/send_expiring_orders_notification', :controller => 'admin/cron', :action => 'expiring_orders_notification'
  map.path 'admin/doctor_payments/upload', :controller => 'admin/doctor_payments', :action => 'upload'
  map.path 'admin/upload', :controller => 'admin/upload', :action => 'upload'
  map.path 'admin/upload_pdf', :controller => 'admin/upload', :action => 'upload_pdf'
  map.path 'admin/mail_templates', :controller => 'admin/mail_templates', :action => 'index'
  map.path 'admin/mail_templates/update', :controller => 'admin/mail_templates', :action => 'update'
  #map.path 'admin/mail_templates/create_new', :controller => 'admin/mail_templates', :action => 'new_template'
  map.path 'admin/mail_templates/:file_name', :controller => 'admin/mail_templates', :action => 'edit'

  map.path 'admin/providers', :controller => 'admin/providers', :action => 'index'
  map.path 'admin/providers/provider_specialities/:doc_id', :controller => 'admin/providers', :action => 'provider_specialities'
  map.path 'admin/providers/provider_services/:doc_id/:spc_id', :controller => 'admin/providers', :action => 'provider_services'


  map.namespace(:doctor_section) do |doctor|
    doctor.resources :services, :active_scaffold => true
    #doctor.resources :doctor_payment, :active_scaffold => true
    doctor.resources :specialties, :active_scaffold => true 
    doctor.resources :doctor_services, :active_scaffold => true 
    doctor.root :controller => 'dashboard', :action => 'index', :conditions => { :method => :get }
    map.path 'doctor_section/dashboard', :controller => 'doctor_section/dashboard', :action => 'index', :conditions => { :method => :get }
    map.path 'doctor_section/procedures', :controller => 'doctor_section/procedures', :action => 'index'
    map.path 'doctor_section/profile', :controller => 'doctor_section/profile', :action => 'index'
    map.path 'doctor_section/profile/save', :controller => 'doctor_section/profile', :action => 'save'
    map.path 'doctor_section/user_session/destroy', :controller => 'user_sessions', :action => 'destroy', :conditions => { :method => :get }
    #map.path 'doctor_section/user_session/admin', :controller => 'user_sessions', :action => 'admin', :conditions => { :method => :get }
    map.path 'doctor_section/closed', :controller => 'doctor_section/closed', :action => 'index'
    map.path 'doctor_section/:action', :controller => 'doctor_section/dashboard', :action => 'index'
  end
  map.doctor_section 'doctor_section/orders/bydoctor/:docid', :controller => 'doctor_section/doctor_orders', :action => 'index', :conditions => { :method => :get }

  map.doctor_section 'doctor_section/orders/index', :controller => 'doctor_section/orders', :action => 'index'
  map.doctor_section 'doctor_section/orders/index/:page', :controller => 'doctor_section/orders', :action => 'index'

  map.doctor_section 'doctor_section/order/:id', :controller => 'doctor_section/orders', :action => 'order'
  #map.doctor_section 'doctor_section/orders/context/:context', :controller => 'doctor_section/orders', :action => 'index'
  map.doctor_section 'doctor_section/orders/context/:context/:page', :controller => 'doctor_section/orders', :action => 'index'

  map.doctor_section 'doctor_section/payment/:id', :controller => 'doctor_section/payments', :action => 'payment'
  #map.doctor_section 'doctor_section/payments', :controller => 'doctor_section/payments', :action => 'index'
  map.doctor_section 'doctor_section/payments/:page', :controller => 'doctor_section/payments', :action => 'index'
  #map.doctor_section 'doctor_section/payments/:search/:query', :controller => 'doctor_section/payments', :action => 'index'

  map.doctor_section 'doctor_section/orders/practice_area/:practice_area', :controller => 'doctor_section/orders', :action => 'index', :conditions => { :method => :get }
  map.doctor_section 'doctor_section/orders/practice_area/:practice_area/:page', :controller => 'doctor_section/orders', :action => 'index', :conditions => { :method => :get }

  map.doctor_section 'doctor_section/signup/:step', :controller => 'doctor_section/signup', :action => 'index'


  map.resources :services
  map.resources :specialties

  map.resources :specialty_services, :only => [:show]
  map.path 'specialty_services/spanish_doctors/:id', :controller => 'specialty_services', :action => 'spanish'
  map.path 'specialty_service_details/:id', :controller => 'specialty_services', :action => 'details'

  map.resources :doctor_services, :only => [:show]
  map.resource :user_session
  map.path 'user_session/destroy', :controller => 'user_sessions', :action => 'destroy', :conditions => { :method => :get }
  map.path 'login', :controller => 'user_sessions', :action => 'new'
  #map.path 'user_session/admin', :controller => 'user_sessions', :action => 'admin'
  #, :conditions => { :method => :get }
  #map.path 'user_session/create_admin', :controller => 'user_sessions', :action => 'create_admin'
  
  map.resources :doctors, :only => [:show]
  
  map.with_options :name_prefix => 'search_', :path_prefix => 'search', :controller => 'search' do |search|
    search.services         'services/:specialty_id/:query', :action => 'services', :defaults => { :specialty_id => 'all', :query => nil }  
    search.specialties      'practice_areas', :action => 'specialties'
    search.doctors          'doctors', :action => 'doctors'
    search.doctors_name     'doctors/name/:query', :action => 'search_doctor_name'
    search.doctors_zipcode  'doctors/zipcode/:zipcode', :action => 'search_doctors_zipcode'
    search.doctors_city     'doctors/city/:city/:state', :action => 'search_doctors_city_state'
    search.doctors_company  'doctors/company/:query', :action => 'search_doctors_company'
  end
  
  # search.doctors_company  'doctors/company/:query', :action => 'search_doctors_clinic'

  map.js_routes 'js_routes.:format', :controller => 'named_routes', :action => 'generate'

  map.page 'page/:slug', :controller => 'pages', :action => 'show'


  map.path 'doctor/register', :controller => 'doctors', :action => 'addnew'
  map.path 'doctor/record', :controller => 'doctors', :action => 'record', :conditions => { :method => :post }
  map.new_doctor  'doctor/register', :controller => 'doctors', :action => 'addnew', :conditions => { :method => :post }
  map.path 'doctor/login', :controller => 'doctors', :action => 'login', :conditions => { :method => :post }

  map.doctor_details '/doctor/details/:id', :controller => 'doctors', :action => 'details', :conditions => {:method => :post}


  map.path 'test', :controller => 'test', :action => 'index'
  map.path 'test/upload', :controller => 'test', :action => 'upload'
  map.path 'autofill/search', :controller => 'auto_fill', :action => 'search'
  map.path 'autofill/search/:context/:query', :controller => 'auto_fill', :action => 'search'


  map.path "contact/form", :controller => 'home', :action => 'contactform'
  map.path "/contact/captcha/valid", :controller => 'home', :action => 'captchavalid'
  map.path "contact/submit", :controller => 'home', :action => 'contactsubmit'
  map.path "subscribe", :controller => 'home', :action => 'subscribe'
  map.path "providerapp", :controller => 'home', :action => 'providerapp'
  map.root :controller => "home", :action => "index" # optional, this just sets the root route

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'

  map.connect '/download/practice_area_documents/:id.pdf', :controller => 'home', :action => 'file_not_found'
  ActionController::Routing::Routes.draw do |map|
  map.resources :line_items

  map.resources :carts

  map.resources :carts

  map.resources :line_items

  map.resources :carts

    map.connect ':controller/:action/:id'
    map.connect '*path', :controller => 'home', :action => 'index'
  end
  


end
