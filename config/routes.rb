Rails.application.routes.draw do
  scope '(:locale)', locale: /en|de/ do
    devise_for :user, controllers: {confirmations: 'user/confirmations',
                                    passwords:     'user/passwords',
                                    registrations: 'user/registrations',
                                    sessions:      'user/sessions',
                                    unlocks:       'user/unlocks'}

    devise_scope :user do
      get :user, to: 'user/registrations#show', as: nil # Helper user_registration_path is already generated by Devise (as POST, but seems to be OK for GET, too)
    end

    resources :users
    resources :pages
    resources :rooms do
      resources :bookings, bookable_type: 'Room', bookable_id: 'room_id'
    end

    [403, 404, 422, 500].each do |code|
      get code, to: 'errors#show', code: code
    end

    root 'homepage#show'
  end
end
