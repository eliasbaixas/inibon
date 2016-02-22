# encoding: utf-8
class Inibon::Version < ActiveRecord::Base

  self.table_name= 'inibon_versions'
  @@logger = ActiveSupport::Logger.new('log/inibon.log')

  def self.model_name
    @my_model_name ||= ::ActiveModel::Name.new(self, Inibon)
  end

  statux %w{wip production deprecated}, required: true, column: :state, initial: 'wip'

  has_many :versionings, class_name: 'Inibon::Versioning', foreign_key: :version_id
  has_many :translations, through: :versionings, class_name: 'Inibon::Translation', source: :version # , foreign_key: :translation_id, source: :versions

  def identification
    "#{self.class.model_name}: #{self.id}"
  end

  def self.param_find(x)
    self.find_by_id(x.to_s)
  end

end
