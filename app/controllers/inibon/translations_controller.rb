class Inibon::TranslationsController < Inibon::BaseController

   def create
    #@thing = @scope.new(params[:thingy])
    extra_params = @chain.inject({}) {|acc,x| acc.update(x.class.model_name.param_key + '_id' => x.id) }
    #@thing = @clazz.new((@scope.proxy_options[:conditions].merge(extra_params) & @clazz.column_names).merge(params[:thingy]))
    @thing = @scope.new(extra_params.merge(params[:thingy])) #@clazz.new((@scope.proxy_options[:conditions].merge(extra_params) & @clazz.column_names).merge(params[:thingy]))

    @version = Inibon::Version.find(Inibon::ArI18n.modify_version)

    if previous = Inibon::Translation.in_locale(@locale).with_key(@key).in_version(@version).last
      previous.versions.delete(@version) 
    end
      
    @thing.versions << @version

    if @thing.save
      @things = @scope.paginate(page: params[:page])
      render 'inibon/index'
    else
      render 'inibon/new'
    end

   end

end
