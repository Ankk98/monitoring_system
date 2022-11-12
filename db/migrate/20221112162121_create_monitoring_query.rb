class CreateMonitoringQuery < ActiveRecord::Migration[5.2]
  def change
    create_table :monitoring_queries do |t|
      t.integer :platform_id
      t.text :params
      t.integer :interval
      t.integer :state
			t.timestamps
    end
  end
end
