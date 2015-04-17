class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :name
      t.string :reference
      t.string :lang, default: 'eng'

      t.timestamps
    end
  end
end
