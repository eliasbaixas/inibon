class Inibon::KeysController < Inibon::BaseController

  before_action :set_key, only: [:show, :edit, :update, :destroy]

  include I18n::Backend::Flatten

  class Unflatten

    attr_accessor :h, :locale

    def initialize(keys, locale)
      @locale=locale
      default = Proc.new {|hash,key| hash[key] = Hash.new(&default) }
      @h=Hash.new(&default)

      keys.each do |k|
        k.split('.').reduce(@h){|acc,slug| acc[slug] }
      end
    end

    def populate
      process = Proc.new do |parent, key|
        last = key.split('.').last
        if parent[last].empty?
          parent[last] = Inibon::Translation.in_locale(@locale).with_key(key).last.try(:value)
        else
          parent[last].each do |k, v|
            process.call(parent[last], "#{key}.#{k}")
          end
        end
      end

      @h.each do |k,v|
        process.call(@h, k)
      end

      {@locale => @h}
    end

  end


  def to_yaml
    @locale = Inibon::Locale.find_by(key: params[:locale] || 'en')
    @u= Unflatten.new(Inibon::Key.all.pluck(:key),params[:locale])
    respond_to do |format|
      format.yaml { render plain: @u.populate.to_yaml }
      format.json { render json: @u.populate }
    end
  end

  def from_yaml
    if request.get?
      @locale = Inibon::Locale.find_by(key: params[:locale] || 'en')
      return
    end

    uploaded_io = params[:yaml].respond_to?(:to_io) ? params[:yaml].to_io : StringIO.new(params[:yaml])
    all = YAML.load(uploaded_io)

    @success,@failure={},{}

    version = Inibon::Version.last

    all.each do |locale_key,hash|
      @locale ||= Inibon::Locale.find_by(key: locale_key) || Inibon::Locale.create(key: locale_key, name: hash['general_lang_name'])

      f = flatten_translations(locale_key,hash,false,false)

      f.each do |k,v|
        Inibon::Key.ensure_key(k) do |b|
          t = Inibon::Translation.in_locale(@locale).with_key(b).build(value: v)
          (t.save ? @success : @failure).update(b.key => t)
          #t.versions << version
        end
      end
    end
  end

  def find
  end

  def create
    Inibon::Key.ensure_key(params[:thingy][:key])
    redirect_to action: :index
  end

  def show

    if @chain.find_all {|x| Inibon::Key === x}.length > 1
      @thing = @clazz.param_find(params[:id])
      @scope = @clazz.where()
      @chain.shift
    else
      unless @thing = @scope.param_find(params[:id])
        redirect_to({action: :index},{error: 'Not Found'})
        return
      end
    end
    render 'inibon/show'
  end

  def index
    if @chain.last.class == Inibon::Key
      @things = @scope.last.children.paginate(page: params[:page])
    else
      @things = @scope.paginate(page: params[:page])
    end
    render 'inibon/index'
  end

end
