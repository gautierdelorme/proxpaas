class CreateProxApps < ActiveRecord::Migration[5.1]
  def change
    create_table :prox_apps do |t|
        t.string :ct_ip
        t.string :ct_id, null: false
        t.timestamps
    end
  end
end
