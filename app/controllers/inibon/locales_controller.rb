class Inibon::LocalesController < Inibon::BaseController

  include I18n::Backend::Flatten

  def missing
    @keys = Inibon::Key.with_missing_locales(@locale.key)

    if request.post?
      l=Inibon::Locale.find_by_key(params[:copy_locale])
      @success,@failure={},{}

      @keys.inject({}){|acc,b| acc.update(b => Inibon::Translation.in_locale(l).with_key(b).last)}.each do |k,t|
        next unless t
        t = Inibon::Translation.in_locale(@locale).with_key(k).build(value: t.value)
        (t.save ? @success : @failure).update(k.key => t)
      end
      @keys = Inibon::Key.with_missing_locales(@locale.key)
    end

  end

  def from_yaml
    uploaded_io = params[:yaml].ergo {|x| x.respond_to?(:to_io) ? x.to_io : StringIO.new(x) }
    all = YAML.load(uploaded_io)

    @success,@failure={},{}

    version = Inibon::ArI18n.modify_version

    all.each do |locale_key,hash|
      @locale ||= Inibon::Locale.create(key: locale_key, name: hash['general_lang_name'])

      f = flatten_translations(locale_key,hash,false,false)

      f.each do |k,v|
        Inibon::Key.ensure_key(k) do |b|
          t = Inibon::Translation.in_locale(@locale).with_key(b).build(value: v)
          (t.save ? @success : @failure).update(b.key => t)
          t.versions << version
        end
      end
    end
  end

end
