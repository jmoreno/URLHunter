class CreatePreys < ActiveRecord::Migration
  def change
    create_table :preys do |t|
      t.string :user

      t.timestamps
    end
  end
end
