# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  after_action :make_gallery, only: [:kakao_auth, :naver_auth, :google_oauth2]
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
  def kakao
    redirect_to "https://kauth.kakao.com/oauth/authorize?client_id=#{ENV['KAKAO_REST_API_KEY']}&redirect_uri=https://easymoji-jwhong1991.c9users.io/users/auth/kakao/callback&response_type=code"
  end
  
  def kakao_auth
    kakao_code = params[:code]
    kakao_base_url = "https://kauth.kakao.com/oauth/token"
    # post방식으로 요청. parameter : 요청 보내는 곳, 보낼 parameter
    kakao_base_response = RestClient.post(kakao_base_url, {grant_type: 'authorization_code',
                                              client_id: ENV['KAKAO_REST_API_KEY'],
                                              redirect_uri: 'https://easymoji-jwhong1991.c9users.io/users/auth/kakao/callback',
                                              code: kakao_code
    })
    
    kakao_res = JSON.parse(kakao_base_response)
    kakao_access_token = kakao_res["access_token"]
    
    # REST API 개발가이드/사용자 정보 요청 부분
    kakao_info_url = "https://kapi.kakao.com/v2/user/me"
    kakao_info_response = RestClient.get(kakao_info_url,
                                    Authorization: "Bearer #{kakao_access_token}")
    
    # puts "haha"
    # puts JSON.parse(info_response)
    @user = User.from_omniauth_kakao(JSON.parse(kakao_info_response))
    
    
    if @user.persisted?
      flash[:notice] = "카카오 로그인에 성공했습니다."
      sign_in_and_redirect @user, event: :authentication
    else
      flash[:notice] = "카카오 로그인에 실패했습니다. 재시도 해주십시오"
      redirect_to new_user_session_path
    end
  end
  
  def naver
    @@state = Devise.friendly_token[0, 20]

    redirect_to "https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=#{ENV['NAVER_CLIENT_ID']}&redirect_uri=https://easymoji-jwhong1991.c9users.io/users/auth/naver/callback&state=#{@@state}"
  end
  
  def naver_auth

    callback_state = params[:state]
    if callback_state.eql?(@@state)
      naver_code = params[:code]
      naver_token_state = Devise.friendly_token[0, 20]
      naver_base_url = "https://nid.naver.com/oauth2.0/token"
      
      naver_base_response = RestClient.post(naver_base_url, {grant_type: 'authorization_code',
                                                             client_id: ENV['NAVER_CLIENT_ID'],
                                                             client_secret: ENV['NAVER_CLIENT_SECRET'],
                                                             state: naver_token_state,
                                                             code: naver_code
      })
      
      naver_res = JSON.parse(naver_base_response)
      puts naver_res
      
      naver_access_token = naver_res["access_token"]
      
      # 프로필 조회
      # 접근 토큰이 만료되었는지 여부에 따라서 분기문을 작성해야 한다.
      # 만료시 갱신을 요청하여 access_token을 다시 받아야 하는 듯.
      naver_info_url = "https://openapi.naver.com/v1/nid/me"
      naver_info_response = RestClient.get(naver_info_url,
                                Authorization: "Bearer #{naver_access_token}")
      
      
      puts JSON.parse(naver_info_response)
      puts "current time : " + Time.now.to_s
      puts Time.now.to_i
      @user = User.from_omniauth_naver(JSON.parse(naver_info_response))
      
      if @user.persisted?
        flash[:notice] = "네이버 로그인에 성공했습니다."
        sign_in_and_redirect @user, event: :authentication
      else
        flash[:notice] = "네이버 로그인에 실패했습니다. 재시도 해주십시오"
        redirect_to new_user_session_path
      end
      
    else
      puts "바람직하지 않은 요청이 들어왔다!!"
      flash[:notice] = "바람직하지 않은 요청입니다."
      redirect_to new_user_session_path
    end
  end
  
  def google_oauth2
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      p request.env['omniauth.auth']
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.google_data'] = request.env['omniauth.auth'].except(:extra) # Removing extra as it can overflow some session stores
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
  end
  
  private
  def make_gallery
    if current_user.galleries.size == 0
      gallery = Gallery.create(title: "기본", description: "기본으로 만들어지는 갤러리 입니다. 내용을 변경하세요.", user_id: current_user.id)
      Emoji.create(remote_image_url: "https://easymoji-jwhong1991.c9users.io/default.png", gallery_id: gallery.id)
    else
    end
  end
  
end
