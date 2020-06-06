class VendingMachineLogger
  def product_selected(name, price)
    puts "Product #{name} was selected. Please insert: #{price}"
    true
  end

  def current_balance(balance, left)
    puts "Current Balance: #{balance}; Please insert: #{left}"
    true
  end

  def product_reselected(name)
    puts "Product #{name} was selected. Enough coins provided"
    true
  end

  def not_enough_coins_for_new_product(name, price, balance)
    puts "Product #{name} was selected. Please insert: #{price}. Current balance: #{balance}"
    true
  end

  def success_purchase(change, name)
    puts "#{change}. Your product: #{name}"
    true
  end

  def display_product(name, in_stock, price)
    puts "#{name}: price - #{price}, in stock - #{in_stock};"
    true
  end

end