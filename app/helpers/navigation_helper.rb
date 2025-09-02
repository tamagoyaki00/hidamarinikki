module NavigationHelper
  def highlight_class(path)
    current_page?(path) ? "text-primary" : "text-gray-500"
  end
end
