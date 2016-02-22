class Inibon::Locale < ActiveRecord::Base

  self.table_name= 'inibon_locales'
  @@logger = ActiveSupport::Logger.new('log/inibon.log')

  def self.model_name
    #@my_model_name ||= ::ActiveSupport::ModelName.new(name.demodulize)
    @my_model_name ||= ::ActiveModel::Name.new(self, Inibon)
  end

  has_many :translations, class_name: 'Inibon::Translation', foreign_key: :locale_id
  has_many :keys, through: :translations, class_name: 'Inibon::Key', foreign_key: :key_id

  scope :in_locale, ->(l) {
    case l
    when  String, Symbol
        where(key: l.to_s)
    else
        where(id: l.id)
    end
  }

  scope :with_key, ->(k) {
    case k
    when  String, Symbol
      joins(:keys).where(inibon_keys: {key: k.to_s.gsub(':','.')})
    else
      joins(:keys).where(inibon_keys: {id: k.id})
    end
  }

  statux %w{wip available disabled}, required: true, column: :state, initial: 'wip'

  validates_uniqueness_of :key

  def self.with_locale(l)
    yield(find_by_key(l.to_s) || Inibon::Locale.create(key: l.to_s))
  end

  def chain
    [@self]
  end

  def identification
    "#{self.class.model_name}: #{self.name}"
  end

  def to_param
    self.key
  end

  def self.param_find(x)
    self.find_by_key(x.to_s)
  end

end
