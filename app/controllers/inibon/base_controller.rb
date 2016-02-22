class Inibon::BaseController < ApplicationController

  before_filter :fetch_scope, except: [:landing]

  def landing
    render 'inibon/landing'
  end

  def show
    unless @thing = @scope.param_find(params[:id])
      redirect_to({action: :index},{error: 'Not Found'})
      return
    end
    render 'inibon/show'
  end

  def index
    @things = @scope.all
    render 'inibon/index'
  end

  def new
    #@thing = @scope.new
    #ActiveRecord::QueryMethods::WhereChain
    @thing = @scope.new #@clazz.new(@scope.proxy_options[:conditions] & @clazz.column_names)
    @chain << @thing
    render 'inibon/new'
  end

  def create
    #@thing = @scope.new(params[:thingy])
    extra_params = @chain.inject({}) {|acc,x| acc.update(x.class.model_name.singular + '_id' => x.id) }
    @thing = @scope.new(extra_params.merge(params[:thingy])) #@clazz.new((@scope.proxy_options[:conditions].merge(extra_params) & @clazz.column_names).merge(params[:thingy]))
    if @thing.save
      @things = @scope.all
      render 'inibon/index'
    else
      render 'inibon/new'
    end
  end

  def update
    @thing = @clazz.find(@scope.param_find(params[:id]).try(:id))
    if @thing.update_attributes(params.require(:thingy).permit!)
      redirect_to [:inibon]+@chain, info: 'OK !'
    else
      render 'inibon/edit'
    end
  end

  def edit
    @thing = @scope.last
    render 'inibon/edit'
  end

  def destroy
    @thing = @scope.last
    @thing.destroy
    redirect_to [:inibon] + @chain[0..-2] + [@clazz.model_name.plural]
  end

  private

  def fetch_scope

    @chain = (request.path.split('/') - ['', 'inibon',params[:action], params[:action]+'!']).
      in_groups_of(2).
      map {|k,v| k.to_s.prepend('inibon/').singularize.camelize.constantize.param_find(v)}.
      compact.
      each {|x| instance_variable_set("@#{x.class.model_name.param_key}",x)}
    @clazz = (request.path - /\/inibon/).
      split('/').
      reverse.
      map(&:singularize).
      find {|x| %w[locale key translation].include?(x)}.
      prepend('inibon/').camelize.constantize
    @scope = {locale_id: :in_locale, key_id: :with_key}.
      inject(@clazz) { |klazz, (k,v)| params[k] ? klazz.send(v,params[k]) : klazz }
  end

end
