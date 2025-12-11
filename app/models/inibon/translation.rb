# encoding: utf-8
class Inibon::Translation < ActiveRecord::Base

  self.table_name= 'inibon_translations'
  @@logger = ActiveSupport::Logger.new('log/inibon.log')

  def self.model_name
    #@my_model_name ||= ::ActiveSupport::ModelName.new(name.demodulize)
    @my_model_name ||= ::ActiveModel::Name.new(self, Inibon)
  end

  #attr_protected :is_proc #, :interpolations

  # validates_uniqueness_of :key

  statux %w{wip production deprecated}, required: true, column: :state, initial: 'wip'

  # serialize :value
  serialize :interpolations, coder: Inibon::JsonCoder

  belongs_to :key, class_name: 'Inibon::Key', foreign_key: :key_id
  belongs_to :locale, class_name: 'Inibon::Locale', foreign_key: :locale_id

  has_many :versionings, class_name: 'Inibon::Versioning', foreign_key: :translation_id
  has_many :versions, through: :versionings# , class_name: 'Inibon::Version', source: :translations

  scope :in_version, ->(v) { joins(:versions).where(inibon_versions: {id: v}) }

  scope :in_locale, ->(l) {
    case l
    when String, Symbol
      joins(:locale).where(inibon_locales: {key: l.to_s})
    else
      where(locale_id: l.id)
    end
  }

  scope :with_key, ->(k) {
    case k
    when String, Symbol
      joins(:key).where(inibon_keys: {key: k.to_s.gsub(':','.')})
    when Array
      joins(:key).where(inibon_keys: {key: k.map(&:to_s).map{|x|x.gsub(':','.')} })
    else
      where(key_id: k.id)
    end
  }

  # def self.lookup(keys)
  #   column_name = connection.quote_column_name('key')
  #   keys = Array(keys).map! { |key| key.to_s }

  #   namespace = "#{keys.last}#{I18n::Backend::Flatten::FLATTEN_SEPARATOR}%"
  #   scoped(:conditions => ["#{column_name} IN (?) OR #{column_name} LIKE ?", keys, namespace])
  # end

  def identification
    "#{self.class.model_name}: #{self.value.to_s.truncate(20)}"
  end

  def interpolates?(key)
    self.interpolations.include?(key) if self.interpolations
  end

  def is_proc
    self.kind == 'proc'
  end

  def value
    value = read_attribute(:value)
    case kind 
    when 'proc'
      Kernel.eval(value)
    when 'json'
      JSON.load(value)
    when 'string'
      value
    end
  end

  def value=(value)
    case value
    when Proc
      # TODO al loro
      raise 'dont know how to serialize a Proc'
      kind = 'proc'
    when String
      kind = 'string'
      self.interpolations= value.scan(/%{([^}]*)}/).flatten.ergo {|x| x.any? ? x : nil}
    when Hash, Array
      recurse = lambda do |acc,v|
        case v
        when String 
          acc.concat(v.scan(/%{([^}]*)}/).flatten) 
        when Hash
          v.values.inject(acc,&recurse)
        when Array
          v.inject(acc,&recurse)
        else
          acc
        end
      end

      self.interpolations= value.inject([],&recurse).ergo {|x| x.any? ? x : nil}
      value = JSON.dump(value)
      kind = 'json'
    else
      value = JSON.dump(value)
      kind = 'json'
    end

    write_attribute(:value, value)
    write_attribute(:kind, kind)
  end

  def self.param_find(x)
    self.find_by_id(x.to_s)
  end

end
