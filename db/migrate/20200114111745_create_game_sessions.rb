class CreateGameSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :game_sessions do |t|
      t.references :user, index: true
      t.string :answer_situation, null: false
      t.timestamps
    end
  end
end
