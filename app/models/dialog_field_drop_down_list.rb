class DialogFieldDropDownList < DialogFieldSortedItem
  def show_refresh_button?
    !!show_refresh_button
  end

  def initial_values
    [[nil, "<None>"]]
  end
end
