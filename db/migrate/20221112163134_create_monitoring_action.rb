class CreateMonitoringAction < ActiveRecord::Migration[5.2]
  def change
    create_table :monitoring_actions do |t|
      t.integer :monitoring_query_id
      t.integer :state
      t.text :results, :limit => 4294967295
			t.boolean :found_new_results, :default => false
			t.boolean :notified, :default => false
			t.timestamps
    end
  end
end
