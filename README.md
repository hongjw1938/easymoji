### Easymoji 배포판
## 0. 초기설정
* template
    - `git clone https://github.com/hongjw1991/fuzen_template.git`
* gem file(아래 추가)
    # uploader
    gem 'carrierwave'
    gem 'mini_magick'
    gem 'fog-aws'
    
    
    # toastr
    gem 'toastr_rails'
    
    # Social login Template
    gem 'bootstrap-social-rails'
    
    # rest client
    gem 'rest-client'
    
    # google oauth
    gem 'omniauth-google-oauth2'
    gem 'figaro'
    
    # devise
    gem 'devise'
* stylesheets and js
    - application.js , application.scss로 이동
    - precompile해제(config/initializers/assets.rb)

## 1. 메인페이지
* route : `home#mainpage` - controller 수정
*
