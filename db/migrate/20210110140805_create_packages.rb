class CreatePackages < ActiveRecord::Migration[6.1]
  def change
    create_table :packages do |t|
      t.string :name
      t.string :depends
      t.string :suggests
      t.string :license
      t.string :md5_sum
      t.string :needs_compilation

      t.timestamps
    end
  end
end
