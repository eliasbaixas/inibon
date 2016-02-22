# encoding: utf-8
class Inibon::VersionsController < ApplicationController

  def show
    @version = Inibon::Version.find(params[:id])
  end

  def new
    @version = Inibon::Version.new
  end

  def edit
    @version = Inibon::Version.find(params[:id])
  end

  def update
    @version = Inibon::Version.find(params[:id])

    if @version.update_attributes(params[:version])
      flash.now[:error]='Unable to save version'
      render 'edit'
    else
      redirect_to({action: :index},messages: 'successfully updated')
    end
  end

  def change
    session[:display_version]= params[:display_version].try(:to_i)
    session[:modify_version] = params[:modify_version].try(:to_i)
    redirect_to action: :index
  end

  def index
    @versions = Inibon::Version.all
  end

  def create
    last_version= Inibon::Version.scoped(order: 'id DESC').first
    @version = Inibon::Version.new(params[:version])

    if @version.save
      @version.translations = last_version.try(:translations) || Inibon::Translation.all
      redirect_to [:inibon,@version]
    else
      render 'new'
    end
  end

end
