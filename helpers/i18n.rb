module I18nUtils
  def link resource, options={}
    locale = params[:locale] || options[:locale]
    url File.join('/', locale, resource)
  end
end

helpers I18nUtils
