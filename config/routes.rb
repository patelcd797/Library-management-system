Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'welcome#index'
  get 'users/checkout', to: "users#checkout"
  resources :users, except: [:new]
  get 'signup', to: 'users#new'
  get 'search', to: 'books#search'
  get 'login', to: 'session#new'
  post 'login', to: 'session#create'
  delete 'logout', to: 'session#destroy'
  resources :checkout_books, only: [:create, :destroy, :update]
  resources :books
  
end
