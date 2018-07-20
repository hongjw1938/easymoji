class EmojisController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:malabi_callback]
  before_action :authenticate_user!, except: [:malabi_callback]
  before_action :get_galleries, except: [:malabi_callback]
  before_action :set_emoji, only: [:show, :edit, :update, :destroy, :preview]


  # GET /emojis
  # GET /emojis.json
  def index
    @emojis = Emoji.all
  end

  # GET /emojis/1
  # GET /emojis/1.json
  def show
  end

  # GET /emojis/new
  def new
    @emoji = Emoji.new(remote_image_url: "https://easymoji-jwhong1991.c9users.io/default.png", gallery_id: params[:gallery_id])
    
    respond_to do |format|
      if @emoji.save
        format.js {render :action => "new"}
      else
        puts @emoji.errors.full_message
        format.js {render "alert('갤러리생성에 실패했습니다!');"}
      end
    end
  end
  
  # preview
  def preview
  end
  
  def upload
    
    puts "ahahaha"
    p params[:emoji][:image][0]
    p params[:emoji][:image][1]
    puts "ahahah231231a"
    
    images = params[:emoji][:image]
    len = images.length
  
    puts len    
    current_gallery = params[:emoji][:gallery_id]
    
    images.each_with_index do |my_image, index|
      @emoji = Emoji.new(image: my_image, gallery_id: params[:emoji][:gallery_id])  
      p @emoji
      
      
      if @emoji.save
        if index+1 == len
          redirect_to gallery_path(current_gallery)
        else
          next
        end
      else
        p @emoji.errors
        if @emoji.errors.full_messages[0].eql?("Image file size must be less than or equal to 2 MB")
          p @emoji.errors
          flash[:danger] = "2MB이하의 이미지만 업로드할 수 있습니다." 
          redirect_to gallery_path(current_gallery) and return true
        elsif @emoji.errors.full_messages[0].eql?("Image dimension 360")
          p @emoji.errors
          flash[:danger] = "반드시 가로 및 세로가 360 크기 이상 이어야 합니다." 
          redirect_to gallery_path(current_gallery) and return true
        else
        end
      end
    end
  end
  # GET /emojis/1/edit
  def edit
  end

  # POST /emojis
  # POST /emojis.json
  def create
    @emoji = Emoji.new(emoji_params)

    respond_to do |format|
      if @emoji.save
        format.html { redirect_to @emoji, notice: 'Emoji was successfully created.' }
        format.json { render :show, status: :created, location: @emoji }
      else
        format.html { render :new }
        format.json { render json: @emoji.errors, status: :unprocessable_entity }
      end
    end
  end



  # DELETE /emojis/1
  # DELETE /emojis/1.json
  def destroy
    gallery = Gallery.find(params[:gallery_id])
    respond_to do |format|
      if gallery.emojis.size <= 1
        
        format.js {render :destroy_error}
      else 
        @emoji_id = params[:id]
        @emoji.destroy
        format.js {render :destroy}
      
      end
    end
  end
  
    
  def update_state
    puts "여기임!"
    @emoji = Emoji.find(params[:emoji_id])
    respond_to do |format|
      if @emoji.update(status: params[:state])
    
        format.js {render :update_state}
        
      end
    end
  end
  
  def update_concept
    @emoji = Emoji.find(params[:id])
    @emoji.touch(:updated_at)
    if @emoji.update(concept: params[:concept])
    else
      p @emoji.errors
    end
    
  end
  
  # GET /galleries/:gallery_id/emojis/:id
  def pixlr_save
    original = Emoji.find(params[:id])
    original.touch(:updated_at)
    
    
    image_to_save = Emoji.new()
    
    puts image_to_save
    
    image_to_save.remote_image_url = params[:image]
    image_to_save.gallery_id = params[:gallery_id]
    
    puts DateTime.new
    
    if image_to_save.save
      render :nothing => true  
    else
      render file: Rails.root.join('public', '500.html')
    end
    
    
    #download = open(image_url)
    #IO.copy_stream
    
    
    
  end
  
  def malabi_process
    current_emoji = Emoji.find(params[:id])
    current_gallery = Gallery.find(params[:gallery_id])
    
    current_emoji.touch(:updated_at)
    
    malabi_base_url = "https://api.malabi.co/v1/images"
    malabi_base_response = RestClient.post(malabi_base_url, { image_url: "https://easymoji-jwhong1991.c9users.io#{current_emoji.image}",
                                                              settings: {
                                                                shadow: "drop",
                                                                background: "white"
                                                              }
                                                            }.to_json,
                                                            {
                                                              content_type: :json,
                                                              accept: :json,
                                                              'x-api-id': ENV["MALABI_API_ID"],
                                                              'x-api-key': ENV["MALABI_API_SECRET"]
                                                            })
  
  json_val = JSON.parse(malabi_base_response)
  
  malabi_processed_image = Emoji.new(gallery_id: current_gallery.id)
  malabi_processed_image.remote_image_url = json_val["image"]["result_image_url"]
  malabi_processed_image.malabi_id = json_val["image"]["id"]
  malabi_processed_image.malabi_secret = json_val["image"]["secret"]
  malabi_processed_image.status = current_emoji.status
  malabi_processed_image.concept = current_emoji.concept
  
  
  puts json_val["image"]["secret"]
  
    respond_to do |format|  
      if malabi_processed_image.save
        format.js { render :malabi_br }
      else
        format.js { render js: "알 수 없는 오류가 발생했습니다. 재시도 해주세요!" }
      end
    end
  
  end
  
  def malabi_callback
    
    current_gallery = Gallery.find(params[:gallery_id])
    original_emoji = Emoji.find(params[:id])
    malabi_processed = Emoji.new(gallery_id: current_gallery.id)
    malabi_processed.remote_image_url = params[:image][:result_image_url]
    malabi_processed.concept = original_emoji.concept
    malabi_processed.status = original_emoji.status
    malabi_processed.malabi_id = params[:image][:id]
    malabi_processed.malabi_secret = params[:image][:secret]
    
    respond_to do |format|
      if malabi_processed.save
        puts "done!"
        
        format.html { redirect_to gallery_path(current_gallery) }
        format.json { redirect_to gallery_path(current_gallery) }
      else
        format.html { render js: "알 수 없는 오류가 발생했습니다." }
        format.json { render js: "알 수 없는 오류가 발생했습니다." }
      end
    end
  end
  
  private
    def get_galleries
      @galleries = current_user.galleries
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_emoji
      @emoji = Emoji.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def emoji_params
      params.require(:emoji).permit()
    end
end
