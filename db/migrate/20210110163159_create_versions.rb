class CreateVersions < ActiveRecord::Migration[6.1]
  def change
    create_table :versions do |t|
      t.string :number
      t.references :package, null: false, foreign_key: true

      t.timestamps
    end
  end
end
