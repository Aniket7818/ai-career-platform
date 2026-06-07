class AddProfileImagesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :avatar, :text
    add_column :users, :cover_image, :text
  end
end
