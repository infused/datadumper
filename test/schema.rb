ActiveRecord::Schema.define(:version => 0) do
  
  create_table :widgets, :force => true do |t|
    t.column :size, :integer
    t.column :name, :string, :limit => 50
  end
  
end