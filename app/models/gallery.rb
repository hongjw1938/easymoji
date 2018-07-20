class Gallery < ApplicationRecord
    belongs_to :user
    has_many :emojis, dependent: :destroy
    

end
