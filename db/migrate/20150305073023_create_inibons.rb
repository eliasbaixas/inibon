class CreateInibons < ActiveRecord::Migration

  def self.up
    create_table "inibon_keys", :force => true do |t|
      t.string   "key"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "ancestry"
      t.integer  "father_id"
      t.integer  "children_count"
    end

    add_index "inibon_keys", ["ancestry"], :name => "index_inibon_keys_on_ancestry"

    create_table "inibon_hits", :force => true do |t|
      t.string   "view"
      t.string   "call_site"
      t.integer  "i18n_translation_id"
      t.integer  "count"
      t.datetime "last_hit"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "inibon_translations", :force => true do |t|
      t.text    "value"
      t.text    "interpolations"
      t.string  "state",          :limit => 10, :default => "wip"
      t.integer "locale_id"
      t.integer "key_id"
      t.string  "kind"
    end

    create_table "inibon_versions", :force => true do |t|
      t.string   "name"
      t.string   "state",      :limit => 10
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "inibon_locales", :force => true do |t|
      t.string   "key",        :limit => 8
      t.string   "state",      :limit => 10, :default => "wip"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
    end

    create_table "inibon_translations_versions", :id => false, :force => true do |t|
      t.integer "translation_id"
      t.integer "version_id"
    end

  end

  def self.down
    drop_table 'inibon_translations'
    drop_table 'inibon_translations_versions'
    drop_table 'inibon_locales'
    drop_table 'inibon_keys'
    drop_table 'inibon_hits'
    drop_table 'inibon_versions'
  end

end
