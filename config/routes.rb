Railsbox::Application.routes.draw do

  match "logs", :to => "logs#index", :via => :post
  resources :logs

  match "searchUsersGroups", :to => "groups#userGroupSearchResult", :via => :post, :as => "user_group_search"
  get "admin/panel"
  
  get "admin/users"
  
  get "admin/groups"

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "users#new", :as => "sign_up"
  
  
  
  root :to => "folders#index"
  
  match "users/search", :to => "users#searchUsersResult", :via => :post, :as => "user_search"
  
  
  match "disk_space", :to => "users#disk_space"
  
  resources :users do
    get :change_password
    put :change_password_update
  end
  
  get "change_password" => "users#change_password", :as => "change_password"
  
  get "resetpassword" => "users#resetPassword", :as => "reset_password"
  post "users/updatePassword", :as => "update_password"
  
  resources :sessions
  
  resources "notassets", :controller => :assets do
    get :rename
  end
  
  resources :hotlinks do
    get :link
  end
  
  resources :permissions, :only => [:destroy,:edit]
  
  resources :folders do
    get :folderChildren, :rename
    resources :permissions
  end

  
  match "groups/search", :to => "groups#searchGroupsResult", :via => :post, :as => "group_search"
  resources :groups do
    resources :userGroup
  end
  
  match "assets/get/:id" => "assets#get", :as => "download_notasset" 
  match "download" => "folders#download", :as => "download", :via => :post
  match "folders/move/:ids" => "folders#move", :as => "move"
  match "folders/details/:id" => "folders#details", :as => "folder_details"
  match "assets/details/:id" => "assets#details", :as => "notasset_details"
  match "my_details" => "users#me", :as=>"my_details"
  match "assets/move/:ids" => "assets#move", :as => "move"
  match "assets/zip/:name/:ids" => "assets#zip", :as => "zip"
  match "search" => "folders#search", :as=> "search"
  match "browse/:folder_id" => "folders#browse", :as => "browse"  
  match "browse/:folder_id/new_folder" => "folders#new", :as => "new_sub_folder"  
  match "browse/:folder_id/new_file" => "assets#new", :as => "new_sub_file"
  match "hotlink/new/:asset_id" => "hotlinks#new", :as => "new_hotlink"
  match "hotlink/:link" => "hotlinks#show", :as => "open_hotlink"
  

  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
