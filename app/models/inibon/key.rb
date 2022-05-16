class Inibon::Key < ActiveRecord::Base

  self.table_name= 'inibon_keys'
  @@logger = ActiveSupport::Logger.new('log/inibon.log')

  def self.model_name
    #@my_model_name ||= ::ActiveSupport::ModelName.new(name.demodulize)
    @my_model_name ||= ::ActiveModel::Name.new(self, Inibon)
  end

  has_ancestry

  has_many :translations, class_name: 'Inibon::Translation', foreign_key: :key_id
  has_many :locales, through: :translations, class_name: 'Inibon::Locale', foreign_key: :locale_id

  belongs_to :father, class_name: 'Inibon::Key', counter_cache: :children_count, optional: true
  has_many :sons, class_name: 'Inibon::Key', foreign_key: :father_id

  # This validation is important, otherwise /inibon/locales/ca/keys becomes @cain=[Inibon::Locale.param_find('ca'),Inibon::Key.param_find(nil)] 
  validates_presence_of :key 

  scope :with_missing_locales, ->(*x) {
    select('inibon_keys.*').joins(<<-joins).where('inibon_translations.id IS NULL AND inibon_keys.children_count IS NULL')
      left outer join inibon_locales on #{x.any? ? "inibon_locales.key IN ('#{x.join('\',\'')}')" : '1'}
      left outer join inibon_translations on inibon_translations.key_id = inibon_keys.id AND inibon_translations.locale_id = inibon_locales.id
      joins
  }

  scope :with_missing_version, ->(a,b) {
    select('inibon_keys.*').joins(<<-joins).where('inibon_versionings_b.translation_id IS NULL')
      INNER JOIN inibon_translations
        ON inibon_translations.key_id = inibon_keys.id
      INNER JOIN inibon_versionings
        ON inibon_versionings.translation_id = inibon_translations.id AND inibon_versionings.version_id = #{a}
      LEFT OUTER JOIN inibon_versionings as inibon_versionings_b
        ON inibon_versionings_b.translation_id = inibon_translations.id
        AND inibon_versionings_b.locale_id = inibon_versionings.locale_id
        AND inibon_versionings_b.version_id = #{b}
      joins
  }

  scope :in_locale, ->(l) {
    case l
    when  String, Symbol
      joins(:locales).where(inibon_locales: {key: l.to_s})
    else
      joins(:locales).where(inibon_locales: {id: l.id})
    end
  }

  scope :with_key, ->(k) { where(key: k.to_s.gsub(':','.')) }

  def diff_to(b)
    # Inibon::Key.
  end

  def self.with_differences(a,b)
    connection.execute(<<-SQL).to_a.to_h
      SELECT inibon_keys.key, inibon_translations.locale_id,  COUNT(DISTINCT inibon_translations.value) as cnt FROM inibon_keys
      LEFT OUTER JOIN inibon_translations
        ON inibon_translations.key_id = inibon_keys.id
      LEFT OUTER JOIN inibon_versionings
        ON inibon_versionings.translation_id = inibon_translations.id AND inibon_versionings.version_id IN (#{a},#{b},NULL)
      GROUP BY inibon_keys.key, inibon_translations.locale_id
      HAVING cnt > 1
    SQL
  end

  def self.ensure_key(b)
    if x = Inibon::Key.find_by_key(b.to_s)
      yield(x) if block_given?
    else
      parts = b.to_s.split('.')
      x = parts.inject(nil) do |parent,el|
        Inibon::Key.find_by_key([*parent.try(:key),el]*'.') || Inibon::Key.create(key: [*parent.try(:key),el]*'.', parent: parent, father: parent)
      end
      yield(x) if block_given?
    end
    x
  end

  def missing_locales
    Inibon::Locale.
      where(['NOT EXISTS (select id from inibon_translations where inibon_translations.locale_id = inibon_locales.id AND inibon_translations.key_id = ?)',self.id])
  end

  def identification
    "#{self.class.model_name}: #{self.key}"
  end

  def to_param
    self.key.gsub('.',':')
  end

  def self.param_find(x)
    self.find_by_key(x.to_s.gsub(':','.'))
  end

end
