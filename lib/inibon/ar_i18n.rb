require 'i18n/backend/base'

module Inibon
  class ArI18n

    cattr_accessor :display_version, :modify_version

    module Missing
      include ::I18n::Backend::Flatten

      def store_default_translations(locale, key, options = {})
        count, scope, default, separator = options.values_at(:count, :scope, :default, :separator)
        return unless default

        separator ||= ::I18n.default_separator
        key = normalize_flat_keys(locale, key, scope, separator)

        unless Inibon::Translation.in_locale('default').with_key(key).exists?
          interpolations = options.keys - ::I18n::RESERVED_KEYS
          #keys = count ? ::I18n.t('i18n.plural.keys', locale: locale, default: [:zero,:one,:other]).map { |k| [key, k].join(FLATTEN_SEPARATOR) } : [key]
          keys = count ? [:zero,:one,:other].map { |k| [key, k].join(FLATTEN_SEPARATOR) } : [key]
          keys.each { |key| store_default_translation(locale, key, interpolations,default) }
        end
      end

      def store_default_translation(locale, key, interpolations,content=nil)
        return unless content

        Inibon::Locale.with_locale('default') do |l|
          Inibon::Key.ensure_key(key) do |b|
            Inibon::Translation.in_locale(l).with_key(b).create(value: content,interpolations: interpolations)
          end
        end

        # translation = Inibon::Translation.new(key: key, value: content)
        # translation.interpolations = interpolations
        # translation.save
      end

      def translate(locale, key, options = {})
        super
      rescue ::I18n::MissingTranslationData => e
        self.store_default_translations(locale, key, options)
        raise e
      end

      def default(locale, object, subject, options = {})
        content = super(locale, object, subject, options)
        if content.respond_to?(:to_str)
          parts = ::I18n.normalize_keys(locale, object, options[:scope], options[:separator])
          key = parts[1..-1].join('.') # remove locale
          store_default_translations(locale, key, options)
        end
        content
      end

    end

    include ::I18n::Backend::Base, ::I18n::Backend::Flatten

    def available_locales
      Inibon::Locale.available.map(&:key)
    end

    def store_translations(locale, data, options = {})
      escape = options.fetch(:escape, true)
      flatten_translations(locale, data, escape, false).each do |key, value|

        Inibon::Locale.with_locale(locale) do |l|
          Inibon::Key.ensure_key(key) do |b|
            Inibon::Translation.in_locale(l).with_key(key).delete_all
            Inibon::Translation.in_locale(l).with_key(b).create(value: value)
          end
        end

      end
    end

    protected

    def lookup(locale, key, scope = [], options = {})
      key = normalize_flat_keys(locale, key, scope, options[:separator])
      result = Inibon::Translation.in_locale(locale).with_key(key).all

      if result.empty?
        nil
      elsif result.first.key.key == key
        result.first.value
      else
        chop_range = (key.size + FLATTEN_SEPARATOR.size)..-1
        result = result.inject({}) do |hash, r|
          hash[r.key.key.slice(chop_range)] = r.value
          hash
        end
        result.deep_symbolize_keys
      end
    end

    # For a key :'foo.bar.baz' return ['foo', 'foo.bar', 'foo.bar.baz']
    def expand_keys(key)
      key.to_s.split(FLATTEN_SEPARATOR).inject([]) do |keys, key|
        keys << [keys.last, key].compact.join(FLATTEN_SEPARATOR)
      end
    end

  end
end
