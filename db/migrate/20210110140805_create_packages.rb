class CreatePackages < ActiveRecord::Migration[6.1]
  def change
    create_table :packages do |t|
      t.string :name
      t.string :depends
      t.string :md5_sum
      t.string :maintainer

      t.timestamps
    end
  end
end
