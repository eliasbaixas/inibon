Inibon::Engine.routes.draw do

  root to: 'base#landing'

  resources :versions do
    collection do
      match :change, via: :all
    end
  end

  resources :locales do
    member do 
      match :from_yaml, via: :post
      match :missing, via: :all
    end
    resources :keys do
      resources :translations
    end
    resources :translations do
      resources :keys
    end
  end

  resources :keys do
    resources :translations
    resources :keys
    resources :locales do
      resources :translations
    end
  end

  resources :translations do
    resources :keys do
      resources :locales, member: {from_yaml: :post}
    end
  end

end
