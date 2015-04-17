class AddAttachmentToWords < ActiveRecord::Migration
  def change
    add_attachment :words, :image
  end
end
