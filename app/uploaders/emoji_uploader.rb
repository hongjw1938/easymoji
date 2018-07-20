class EmojiUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :store_dimensions
  # process scale: [360, 360]
  
  # def scale(width, height)
  #   if file && model
  #     model.width, model.height = ::MiniMagick::Image.open(file.file)[:dimensions]
  #   end
  # end
  
  
  # def store_dimensions
  #   if file && model
  #     model.width, model.height = ::MiniMagick::Image.open(file.file)[:dimensions]
  #   end
  # end

  # Create different versions of your uploaded files:
  
  # process :convert_file_to_png
  
  # p file.type
  
  # def convert_file_to_png
  #   manipulate!(format: "png", read: { density: 400 }) do |options|
  #     options = { quality: 100 }
  #   end
  # end
  
  version :thumb_fix, :if => :right_dimension? do
    process :resize_to_fill => [360, 360]
    process :convert => 'png'
  end
  
  

  version :thumb_fit do
    process resize_to_fit: [215, 215]
    process :convert => 'png'
  end
  # Create different versions of your uploaded files:
  version :thumb_fill do
    process resize_to_fill: [215, 215]
    process :convert => 'png'
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(jpg png jpeg JPG) + %w(PNG)
  end
  
  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{secure_token}.png" if original_filename.present?
  end
  
  
  
  protected
  def right_dimension?(my_file)
    width, height = ::MiniMagick::Image.open(file.file)[:dimensions]
    # p ::MiniMagick::Image.open(file.file)[:format]
  
    @dimension_if = (width > 360 and height >= 360) or (width >= 360 and height > 360)
  end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

end
