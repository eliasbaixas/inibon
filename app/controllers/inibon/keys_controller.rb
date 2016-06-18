class Inibon::KeysController < Inibon::BaseController

  def find
  end

  def create
    Inibon::Key.ensure_key(params[:thingy][:key])
    render 'inibon/index'
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
