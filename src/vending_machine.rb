require_relative './vending_machine_errors/errors'
require_relative './vending_machine_logger'

class VendingMachine
  PRODUCTS = {
    'coca-cola' => { price: 100, in_stock: 15, name: 'Coca Cola', key: 'coca-cola' },
    'bigmac' => { price: 250, in_stock: 15, name: 'BigMac', key: 'bigmac' },
    'the-cake' => { price: 400, in_stock: 15, name: 'The Cake', key: 'the-cake' }
  }.freeze

  COINS = {
    '50' => 100,
    '100' => 100,
    '25' => 100,
    '200' => 100,
    '500' => 100
  }.freeze

  COINS_MAP = {
    '25c' => 25,
    '50c' => 50,
    '$0.25' => 25,
    '$0.5' => 50,
    '$1.0' => 100,
    '$2.0' => 200,
    '$5.0' => 500
  }

  def initialize
    @in_stock = start_products
    @coins_in_stock = start_coins
    @selected_product = nil
    @inserted_coins = {}
    @inserted_coins_sum = 0
    @logger = VendingMachineLogger.new
  end

  def select_product(product_name)
    @selected_product = @in_stock[normalize_name(product_name)]

    raise VendingMachineErrors::ProductNotFound unless @selected_product

    if @selected_product[:in_stock].zero?
      @selected_product = nil
      raise VendingMachineErrors::ProductOutOfStock
    end

    @logger.product_selected(@selected_product[:name], humanized_price(@selected_product[:price]))
  end

  def insert_coin(coin)
    raise VendingMachineErrors::ProductNotSelected unless @selected_product

    value = coin_to_value(coin)

    raise VendingMachineErrors::CoinNotValid unless @coins_in_stock[value.to_s]

    @inserted_coins[value.to_s] = (@inserted_coins[value.to_s] || 0) + 1
    @inserted_coins_sum += value

    if @inserted_coins_sum >= @selected_product[:price]
      perform_transaction
    else
      @logger.current_balance(humanized_price(@inserted_coins_sum), 
        humanized_price(@selected_product[:price] - @inserted_coins_sum)) 
    end
  end

  def change_product(product_name)
    validated_product = @in_stock[normalize_name(product_name)]

    raise VendingMachineErrors::ProductNotFound unless validated_product

    raise VendingMachineErrors::ProductOutOfStock if validated_product[:in_stock].zero?

    @selected_product = validated_product
    if @inserted_coins_sum >= @selected_product[:price]
      @logger.product_reselected(@selected_product[:name])
      perform_transaction
    else
      @logger.not_enough_coins_for_new_product(@selected_product[:name], 
        humanized_price(@selected_product[:price]), humanized_price(@inserted_coins_sum))
    end
  end

  def display_in_stock
    @in_stock.values.each do |product|
      @logger.display_product(product[:name], product[:in_stock], humanized_price(product[:price]))
    end
    true
  end

  private

  def perform_transaction
    left, change = calculate_change(@inserted_coins_sum - @selected_product[:price])
    @inserted_coins = {}
    @inserted_coins_sum = 0

    if change
      success_transaction(left, change)
    else
      @selected_product = nil
      raise VendingMachineErrors::ChangeCantBeProvided
    end
  end
  
  def success_transaction(left, change)
    @coins_in_stock = left
    @in_stock[@selected_product[:key]][:in_stock] = @in_stock[@selected_product[:key]][:in_stock] - 1
    name = @selected_product[:name]
    @selected_product = nil
    @logger.success_purchase(humanized_change(change), name)
  end


  def calculate_change(inserted_money)
    available_coins = @coins_in_stock.merge(@inserted_coins) { |_key, old_v, new_v| old_v.to_i + new_v.to_i }
    best_left = find_best(inserted_money, available_coins)
    if best_left
      [best_left, available_coins.merge(best_left) { |_key, old_v, new_v| old_v.to_i - new_v.to_i }]
    else
      [false, false]
    end
  end

  def find_best(sum, available_coins)
    return available_coins if sum.zero?

    if available_coins[sum.to_s].to_i.positive?
      available_coins.merge({ sum.to_s => available_coins[sum.to_s] - 1 })
    elsif available_coins.values.sum.zero?
      nil
    else
      find_best_and_select(sum, available_coins)
    end
  end

  def find_best_and_select(sum, available_coins)
    best = nil
    available_coins.each_pair do |key, value|
      key_int = key.to_i
      if value.positive? && sum > key_int
        current = find_best(sum - key_int, available_coins.merge({ key => value - 1 }))
        best = current if (current && !best) || (current && current.values.sum > best.values.sum)
      end
    end
    
    best
  end

  def normalize_name(name)
    name.downcase.tr(' ', '-')
  end

  def humanized_price(cents)
    "$#{cents.to_i / 100.0}"
  end

  def coin_to_value(coin_str)
    COINS_MAP[coin_str]
  end

  def humanized_change(change)
    str = 'Your change:'

    change.each_pair do |coin, count|
      str += " #{count} x #{humanized_price(coin)};" if count.positive?
    end

    str == 'Your change:' ? 'Change not required' : str
  end

  def start_products
    PRODUCTS.clone
  end

  def start_coins
    COINS.clone
  end
end
