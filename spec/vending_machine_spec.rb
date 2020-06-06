require_relative 'spec_helper'
require_relative '../src/vending_machine_errors/errors'
require_relative '../src/vending_machine'
require_relative '../src/vending_machine_logger'

describe VendingMachine do
  let(:all_products) do
    {
      'coca-cola' => { price: 100, in_stock: 15, name: 'Coca Cola', key: 'coca-cola' },
      'bigmac' => { price: 250, in_stock: 0, name: 'BigMac', key: 'bigmac' },
      'the-cake' => { price: 400, in_stock: 15, name: 'The Cake', key: 'the-cake' }
    }
  end

  let(:all_coins) do
    {
      '50' => 1,
      '100' => 0,
      '25' => 2,
      '200' => 0,
      '500' => 0
    }
  end

  let(:klass) { VendingMachine }
  let(:vending_machine) { klass.new }
  let(:logger_klass) { VendingMachineLogger }

  before(:each) do
    # Disalbe promting to console
    logger_klass.any_instance.stub(puts: nil)
  end

  context 'VendingMachine' do
    context '#select_product' do
      let(:correct_product_name) { all_products.values.first[:name] }
      let(:wrong_product_name) { 'fake product' }
      let(:not_accurate_product_name) { all_products.keys.first.tr('-', ' ').upcase }
      let(:out_of_stock_product_name) { all_products.values.select { |product| product[:in_stock].zero? }.first[:key] }

      before(:each) do
        klass.any_instance.stub(start_products: all_products)
      end

      it 'should correctly select product with valid name' do
        vending_machine.select_product(correct_product_name)
        expect(vending_machine.instance_variable_get(:@selected_product)).not_to be_nil
      end

      it 'should throw error if product name is wrong' do
        expect { vending_machine.select_product(wrong_product_name) }.to raise_error(VendingMachineErrors::ProductNotFound)
        expect(vending_machine.instance_variable_get(:@selected_product)).to be_nil
      end

      it 'should correctly select product with not accurate product name' do
        vending_machine.select_product(not_accurate_product_name)
        expect(vending_machine.instance_variable_get(:@selected_product)).not_to be_nil
      end

      it 'should raise error if product is out of stock' do
        expect { vending_machine.select_product(out_of_stock_product_name) }.to raise_error(VendingMachineErrors::ProductOutOfStock)
      end

    end

    context '#insert_coin' do
      let(:correct_product_name) { all_products.values.first[:key] }
      let(:valid_coin) { all_coins.keys.first }
      let(:invalid_coin) { '999' }
      let(:big_coin) { all_coins.keys.max { |value| value.to_i } }
      let(:cola_coin) { '200' }

      before(:each) do
        klass.any_instance.stub(start_products: all_products)
        klass.any_instance.stub(start_coins: all_coins)
      end

      it 'should collect inserted coin correctly' do
        vending_machine.select_product(correct_product_name)
        vending_machine.insert_coin("$#{valid_coin.to_i / 100.0}")
        expect(vending_machine.instance_variable_get(:@inserted_coins)).not_to be_nil
        expect(vending_machine.instance_variable_get(:@inserted_coins)[valid_coin]).to eq(1)
      end

      it 'should raise error if coin is not valid' do
        vending_machine.select_product(correct_product_name)
        expect { vending_machine.insert_coin(invalid_coin) }.to raise_error(VendingMachineErrors::CoinNotValid)
        expect(vending_machine.instance_variable_get(:@inserted_coins)).to eq({})
      end

      it 'should raise error if coin inserted before product selected' do
        expect { vending_machine.insert_coin("$#{valid_coin.to_i / 100.0}") }.to raise_error(VendingMachineErrors::ProductNotSelected)
        expect(vending_machine.instance_variable_get(:@inserted_coins)).to eq({})
      end

      it 'should raise error if there not enough change' do
        vending_machine.select_product(correct_product_name)
        expect { vending_machine.insert_coin("$#{big_coin.to_i / 100.0}") }.to raise_error(VendingMachineErrors::ChangeCantBeProvided)
        expect(vending_machine.instance_variable_get(:@inserted_coins)).to eq({})
        expect(vending_machine.instance_variable_get(:@coins_in_stock)).to eq(all_coins)
      end

      it 'should return product and change' do
        before_in_stock = vending_machine.instance_variable_get(:@in_stock)[correct_product_name][:in_stock]
        before_coins = vending_machine.instance_variable_get(:@coins_in_stock)
        

        vending_machine.select_product(correct_product_name)
        vending_machine.insert_coin("$#{cola_coin.to_i / 100.0}")

        expect(vending_machine.instance_variable_get(:@in_stock)[correct_product_name][:in_stock])
          .to eq(before_in_stock - 1)
        expect(vending_machine.instance_variable_get(:@coins_in_stock)[cola_coin])
          .to eq(before_coins[cola_coin] + 1)
        expect(vending_machine.instance_variable_get(:@coins_in_stock).values.sum)
          .to eq(1)
      end
    end

    context "#change_product" do
      let(:correct_product_name) { all_products.values.first[:key] }
      let(:correct_product_name_2) { all_products.values.last[:key] }

      before(:each) do
        klass.any_instance.stub(start_products: all_products)
      end

      it 'should change current product' do
        vending_machine.select_product(correct_product_name)
        vending_machine.change_product(correct_product_name_2)
        expect(vending_machine.instance_variable_get(:@selected_product)[:key]).to eq(correct_product_name_2)
      end
    end
  end
end
