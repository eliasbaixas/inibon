# encoding: utf-8
module Inibon::ViewHelpers

  # if we want translations outside ActionView, we need to have a #translate method:
  module SimpleTranslate

    def translate(*args)
      ::I18n.translate(*args).to_s.html_safe
    end

  end

  def self.included(base)
    unless ActionView::Base === base
      base.instance_eval do 
        include SimpleTranslate
        extend SimpleTranslate
      end
    end
  end

  def self.with_locale(locale)
    oldloc = ::I18n.locale
    ::I18n.locale = locale
    yield
    ::I18n.locale = oldloc
  end

  def l(*args)
    opts = args.extract_options!
    x=case args.size
      when 0, 1
        translate(*args,opts)
      else
        case args[1]
        when String
          translate(args.first, opts.merge(default: args[1]))
        when Number
          translate(args.first, opts.merge(count: args[1]))
        else
          raise "Translation string with multiple values: #{args.first}"
        end
      end

      x=x.gsub("\n","<br />") unless opts[:nobr]

      unless opts[:nohtml] || Rails.env.production?
        k=[::I18n.locale,args.first,*opts[:scope]].compact.join('.')
        #"<span class=\"inibon\" data-inibon-key=\"#{k}\">#{h(x)}</span>"
        "<span class=\"inibon\" data-inibon-key=\"#{k}\">#{x}</span>".html_safe
      else
        if opts[:mark]
          "<span class=\"inibon\" data-inibon-key=\"#{k}\"></span>#{x}".html_safe
        else
          x
        end
      end
  end

  def genderized(message, gender, options={})
    case gender
    when 1
      l(:"#{message}_masculine", options.merge(:default=>message))
    when 2
      l(:"#{message}_feminine", options.merge(:default=>message))
    else
      l(message, options)
    end
  end

  def l_or_humanize(s, options={})
    k = "#{options[:prefix]}#{s}".to_sym
    h ::I18n.t(k, :default => s.to_s.humanize)
  end

  def l_hours(hours)
    hours = hours.to_f
    l((hours < 2.0 ? :label_f_hour : :label_f_hour_plural), :value => ("%.2f" % hours.to_f))
  end

  def ll(lang, str, value=nil)
    h ::I18n.t(str.to_s, :value => value, :locale => lang.to_s.gsub(%r{(.+)\-(.+)$}) { "#{$1}-#{$2.upcase}" })
  end

  def format_date(date)
    return nil unless date
    Setting.date_format.blank? ? ::I18n.l(date.to_date) : date.strftime(Setting.date_format)
  end

  def format_time(time, include_date = true)
    return nil unless time
    time = time.to_time if time.is_a?(String)
    zone = nil # User.current.time_zone
    local = zone ? time.in_time_zone(zone) : (time.utc? ? time.localtime : time)
    Setting.time_format.blank? ? ::I18n.l(local, :format => (include_date ? :default : :time)) : 
      ((include_date ? "#{format_date(time)} " : "") + "#{local.strftime(Setting.time_format)}")
  end

  def day_name(day)
    ::I18n.t('date.day_names')[day % 7]
  end

  def month_name(month)
    ::I18n.t('date.month_names')[month]
  end

  def valid_languages
    I18n.available_locales
    #AppConfig.languages.map(&:to_sym)
    #@@valid_languages ||= Dir.glob(File.join(Rails.root, 'config', 'locales', '*.yml')).collect {|f| File.basename(f).split('.').first}.collect(&:to_sym)
  end

  def find_language(lang)
    @@languages_lookup ||= valid_languages.inject({}) {|k, v| k[v.to_s.downcase] = v; k }
    @@languages_lookup[lang.to_s.downcase]
  end

  def current_language
    ::I18n.locale
  end

  def set_language_if_valid(lang)
    if l = find_language(lang)
      ::I18n.locale = l
    end
  end
end
