class Inibon::KeysController < Inibon::BaseController

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
      @things = @scope.last.children
    else
      @things = @scope.all
    end
    render 'inibon/index'
  end

end
