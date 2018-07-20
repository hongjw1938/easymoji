class GalleriesController < ApplicationController
  before_action :authenticate_user!
  before_action :get_galleries
  before_action :set_gallery, only: [:show, :edit, :update, :destroy, :sort]
  
  def index
    
  end

  # GET /galleries/1
  # GET /galleries/1.json
  def show
    if params[:sort_level].present?
      sort = params[:sort_level]
      get_emojis(sort)
    else
      get_emojis("work_order")
    end
  end

  # GET /galleries/new
  def new
    if current_user.galleries.size >= 3
      respond_to do |format|
        format.js {render :error}
      end
    else
      @gallery = Gallery.new
    end
  end

  # GET /galleries/1/edit
  def edit
  end

  # POST /galleries
  # POST /galleries.json
  def create
    
    @gallery = Gallery.new(gallery_params)
    @gallery.user_id = current_user.id
    
    
    if @gallery.save
      p "what the hell?"
      @emoji = Emoji.new(remote_image_url: 'https://easymoji-jwhong1991.c9users.io/default.png', gallery_id: @gallery.id)
      if @emoji.save
        flash[:info] = "갤러리가 생성되었습니다."
        redirect_to gallery_path(@gallery) and return true
      else
        p @emoji.errors
        flash[:danger] = "갤러리 생성에 실패했습니다."
        redirect_to gallery_path(@gallery) and return true
        # flash[:notice] = "갤러리가 생성되었습니다."  
      end
    else
      puts errors
      format.html { render :new }
    end
  end

  # PATCH/PUT /galleries/1
  # PATCH/PUT /galleries/1.json
  def update

    respond_to do |format|
      if @gallery.update(title: params[:title])
        format.js { render :update}
      else
        format.js { render :update_error }
      end
    end
  end

  # DELETE /galleries/1
  # DELETE /galleries/1.json
  def destroy
    if current_user.galleries.size <= 1
      render js: "alert('갤러리가 하나 이하일 땐 삭제할 수 없습니다.');"
    else
      @gallery.destroy
      respond_to do |format|
        format.js {render :destroy}
      end
    end
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    
    def get_galleries
      @galleries = current_user.galleries
    end
    
    def set_gallery
      @gallery = Gallery.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gallery_params
      params.fetch(:gallery, {}).permit(:title, :description)
    end
    
    def get_emojis(sort)
      emojis = Gallery.find(params[:id]).emojis
      @emojis = emojis.order_with(sort)
    end
end
