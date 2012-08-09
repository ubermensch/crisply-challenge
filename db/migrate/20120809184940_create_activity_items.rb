class CreateActivityItems < ActiveRecord::Migration
  def change
    create_table :activity_items do |t|
      t.string :text
      t.string :type
      t.string :guid
      t.boolean :sent_to_crisply
      t.timestamps
    end
  end
end
