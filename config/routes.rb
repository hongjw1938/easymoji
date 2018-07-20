Rails.application.routes.draw do
  

  root 'home#mainpage'
  
  resources :galleries do
    resources :emojis, except: [:create, :update]
  end
  patch "/update_state" => "emojis#update_state", as: "emoji_state"
  patch "/update_concept" => "emojis#update_concept", as: "update_concept"
  
  
  devise_for :user, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get '/users/auth/kakao', to: 'users/omniauth_callbacks#kakao'
    get '/users/auth/kakao/callback', to: 'users/omniauth_callbacks#kakao_auth'
    
    
    get '/users/auth/naver', to: 'users/omniauth_callbacks#naver'
    get '/users/auth/naver/callback', to: 'users/omniauth_callbacks#naver_auth'
  end
  
  get '/galleries/:gallery_id/emojis/:id/save' => "emojis#pixlr_save"

  post '/emoji/preview' => 'emojis#preview'
  post '/emoji/upload' => 'emojis#upload'
  
  post '/galleries/:gallery_id/emojis/:id/background_remove' => "emojis#malabi_process", as: "background_remove"
  match '/galleries/:gallery_id/emojis/:id/malabi_callback' => "emojis#malabi_callback", via: [:post]
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
