module PageUtils
  def title t
    @title = t
  end

  def link_resource type, resource, options={}
    ext = options[:ext] || type
    url "/#{type}/#{resource}.#{ext}"
  end

  def css r; link_resource 'css', r; end
  def js r;  link_resource 'js', r;  end

  def img resource
    url "/img/#{resource}"
  end
end

helpers PageUtils
