class Axiom::TestsController < ApplicationController

  def set_session_variable

    if Rails.env.test?
      ignore = ['action', 'controller']
      params.each do | key, value|
        unless ignore.include?(key)
          session[key.to_sym] = value
        end
      end
    end

    redirect_to '/'

  end

end