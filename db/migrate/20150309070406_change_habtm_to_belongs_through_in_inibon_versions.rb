class ChangeHabtmToBelongsThroughInInibonVersions < ActiveRecord::Migration

  def self.up
    create_table :inibon_versionings do |t|
      t.integer :translation_id
      t.integer :locale_id
      t.integer :version_id
    end
    drop_table :inibon_translations_versions
  end

  def self.down
    create_table :inibon_translations_versions, :id => false, :force => true do |t|
      t.integer :translation_id
      t.integer :version_id
    end
    drop_table :inibon_versionings
  end

end
