class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :line_id, null: false, unique: true
      t.boolean :unsubscrided
      t.datetime :unsubscrided_at

      t.timestamps
    end
  end
end
