Rails.application.routes.draw do
  namespace :line do
    namespace :api do
      post '/' , action: 'callback'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
