class Inibon::Versioning < ActiveRecord::Base

  self.table_name= 'inibon_versionings'
  @@logger = ActiveSupport::Logger.new('log/inibon.log')

  belongs_to :translation, class_name: 'Inibon::Translation', foreign_key: :translation_id
  belongs_to :version, class_name: 'Inibon::Version', foreign_key: :version_id
  belongs_to :locale, class_name: 'Inibon::Locale', foreign_key: :locale_id

  before_save :set_locale_from_translation

  def set_locale_from_translation
    self.locale = self.translation.locale
  end

end
