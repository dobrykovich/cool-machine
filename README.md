## Readme

## Instalation

1. run `bundle` 
2. run irb
3. type `require('./src/vending_machine')`
4. create new instance of class `VendingMachine`

## How to use

Main class is `VendingMachine`. It has 4 public methods and initializer. 
Initializer should be called without any arguments. 

Public methods: 

1. `display_in_stock` - no arguments, will display all available products
2. `select_product` - receives `product_name` as argument and select it as a current product
3. `insert_coin` - receives `coin` as argument and add it to other inserted coins. Once needed amount received will process transaction
4. `change_produc` - receives `product_name` as argument and change current product to new one. If amount of coins is enough, transaction will be processed

### Data

All data stored inside constants in `VendingMachine` class. It can be modified according to needs

### Tests

Run `rspec ./spec` in order to execute tests

### Example usage 


```
instance = VendingMachine.new
instance.display_in_stock
# Coca Cola: price - $1, in stock - 5;

instance.select_product('Coca Cola')
# Product Coca Cola was selected. Please insert: $1.0

instance.insert_coin('25c')
# Current Balance: $0.25; Please insert: $0.5

instance.insert_coin('25c')
# Current Balance: $0.5; Please insert: $0.25

instance.insert_coin('$5.0')
# Your change: 1 x $0.5; 2 x $2.0;. Your product: Coca Cola

instance.display_in_stock
# Coca Cola: price - $1, in stock - 4;
```
