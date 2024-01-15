class CreateUserPasswords < ActiveRecord::Migration[7.1]
  def change
    create_table :user_passwords do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :password, null: false, foreign_key: true
      t.string :role, null: false

      t.timestamps
    end
  end
end
