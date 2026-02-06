class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :name
      t.string :faculty
      t.string :strong_subject
      t.string :weak_subject
      t.string :study_style
      t.string :available_time
      t.text :bio

      t.timestamps
    end
  end
end
