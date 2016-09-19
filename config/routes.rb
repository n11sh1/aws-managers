Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :ec2_managers, only: [:index]

  get '/ec2_managers/start_instance/:instance_id' => 'ec2_managers#start_instance'
  get '/ec2_managers/stop_instance/:instance_id' => 'ec2_managers#stop_instance'
end
