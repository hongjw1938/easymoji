class Emoji < ApplicationRecord
    mount_uploader :image, EmojiUploader
    belongs_to :gallery
    
    # validates :width, numericality: { only_integer: true,
    #                                   equal_to: 360,
    #                                   message: "가로 세로 모두 360이어야 합니다."}
                                      
    # validates :height, numericality: { only_integer: true,
    #                                   equal_to: 360,
    #                                   message: "가로 세로 모두 360이어야 합니다."}                                      
    
    validates :validate_minimum_image_dimension,
                :image, file_size: { less_than_or_equal_to: 2.megabytes }

    
    
    def validate_minimum_image_dimension

      image = MiniMagick::Image.open("https://easymoji-jwhong1991.c9users.io" + self.image.url)
      if image[:width] < 360 or image[:height] < 360
        errors.add :image_dimension, 360 
      end
    end
    
    
    
    def self.order_with(sort_with)
        if sort_with.eql?("work_order")
            emojis = self.order(updated_at: :asc, created_at: :asc)
        elsif sort_with.eql?("create_order")
            emojis = self.order(created_at: :asc)
        else
            emojis = self.order(status: :desc)
        end
    end
end
