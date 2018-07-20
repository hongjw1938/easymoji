class CreateEmojis < ActiveRecord::Migration[5.0]
  def change
    create_table :emojis do |t|
      t.string  :concept             , default: "no concept"
      t.string  :image
      t.string  :status              , default: "draft"
      
      t.integer :gallery_id

      
      
      t.integer :malabi_id
      t.string  :malabi_secret
      t.timestamps
    end
  end
end
