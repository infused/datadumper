# Dumps records from an ActiveRecord model to a format suitable for including into an ActiveRecord::Migration. 
# 
# Options:
# <tt>:ignore_blanks</tt> If set to true, fields with blank fields will not be included in the migration.
# <tt>:except</tt> One or more fields that should not be included in the migration.
# <tt>:only</tt> One or more fields that should be included in the migration.  All other fields will be left out.
# <tt>:retain_id</tt> If set to true, the primary key will be set explicitly.  See the "output formats" below.
# <tt>:output</tt> Specifies the output file name.  The default output filename is RAILS_ROOT/db/migrations/MODELNAME_migration.rb
# <tt>:conditions</tt> Conditions that should be passed to Model.find in case you don't want all the records.
# <tt>:map</tt> A hash of field names that should be converted.  Each field matching a key will be renamed to the value.  This is
# very useful for converting from legacy databases. See the the examples below.
#
# Example:
#
# # dump all records in the standard format
# User.dump_to_migration
#
# # dump all records, but leave out the last_name and password fields
# User.dump_to_migration :except => [:last_name, :password]
#
# # dump all records, but only include the name column
# User.dump_to_migration :only => :name
# 
# # dump only those records matching certain conditions
# User.dump_to_migration :conditions => "last_name like 'a%'"
#
# # rename columns
# User.dump_to_migration :map => {:GroupID => :group_id, :Enabled => :enabled}
#
# Output Formats:
# 
# The normal format is to use the Model.create method, so the records will be dumped like this:
# User.create :name => "Keith", :group_id => 1, :enabled => 1
# User.create :name => "Scott", :group_id => 2, :enabled => 1
#
# If the :retain_id option is set to true the output format will be a little different, because the create method will not
# let you specify an id.
# record = User.new :name => "Keith", :group_id => 1, :enabled => 1
# record.id = 10
# record.save
# record = User.new :name => "Scott", :group_id => 2, :enabled => 1
# record.id = 12
  
  module DataDumper
  
    def dump_to_migration(*args)
      except = [:id, :updated_at, :updated_on, :created_at, :created_on, :version, :lock_version]
      options = extract_options_from_args!(args)
      options[:except] = [*options[:except]] | except
      path = options[:output]
      conditions = options[:conditions]
      path ||= "db/migrate/#{clean_classify(table_name).downcase}_migration.rb"
      migration = self.find(:all, :conditions => conditions).collect do |record|
        a = []
        record.attributes(options).each do |key,value|
          value = case value
          when Numeric
            value
          when String
            options[:ignore_blanks] && value.strip.blank? ? nil : "\"#{value.strip}\""
          else
            options[:ignore_blanks] && value.blank? ? nil : "\"#{value}\""
          end
          a << ":#{map(key, options)} => #{value}" unless value.nil?
        end
        if options[:retain_id] == true
          "record = #{clean_classify(table_name)}.new(#{a.join(', ')})\rrecord.id = #{record.id}\rrecord.save\r"
        else
          "#{clean_classify(table_name)}.create(#{a.join(', ')})"
        end
      end
      write_file(File.expand_path(path, RAILS_ROOT), migration)
    end

    def write_file(path, content)
      File.open(path, "w+") {|f| f.puts content}
    end
  
    def map(column, options)
      options[:map] && options[:map].has_key?(column.to_sym) ? options[:map][column.to_sym] : column.to_sym
    end
  
    def clean_classify(string)
      string.gsub(/"/, "").classify
    end
  
  
end