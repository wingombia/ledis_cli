Rails.application.routes.draw do
  root 'ledis#cli'
  post 'parse', to: 'ledis#parse', default: { format: :json } 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
