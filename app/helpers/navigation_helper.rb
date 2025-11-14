module NavigationHelper
  def highlight_class(path)
    current_page?(path) ? "text-primary" : ""
  end
end
