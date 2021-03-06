class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_menu
  before_filter :store_location, :current_cart


def current_cart
  if session[:cart_id]
    @current_cart ||= Cart.find(session[:cart_id])
    session[:cart_id] = nil if @current_cart.purchased_at
  end
  if session[:cart_id].nil?
    @current_cart = Cart.create!
    session[:cart_id] = @current_cart.id
  end
  @current_cart
end


def store_location
  # store last url - this is needed for post-login redirect to whatever the user last visited.
  return unless request.get? 
  if (request.path != "/users/sign_in" &&
      request.path != "/users/sign_up" &&
      request.path != "/users/password/new" &&
      request.path != "/users/password/edit" &&
      request.path != "/users/confirmation" &&
      request.path != "/users/sign_out" &&
      !request.xhr?) # don't store ajax calls
    session[:previous_url] = request.fullpath 
  end
end

  def after_sign_in_path_for(resource)
  session[:previous_url] || root_path
end

# def after_sign_out_path_for(resource_or_scope)
#   root_path
# end

  def set_menu
    @footer_menus ||= Contact.where(:home_page => true).order(:order)
  	@menus ||= Category.all
  	@headers ||= Category.where(:is_menu => true)
    @budget ||=Item.where(:is_discounted => true)
    @hotdeal ||=Item.where(:is_hot_deal => true).order("RANDOM()") 
    @featured ||=Item.where(:is_featured => true)
    @cart_session ||= session[:cart]
    @cart ||= LinesItem.where(cart_id: @cart_session)
    @wishlist_count ||= ::Wishlist.where(session[:user_id]).count
  end

def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :name, :phone_number, :address) }
  end

end
