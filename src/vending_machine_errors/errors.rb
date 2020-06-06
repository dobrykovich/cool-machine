class VendingMachineErrors
  class ProductNotFound < StandardError
    def message
      'Wrong product selected'
    end
  end

  class ProductOutOfStock < StandardError
    def message
      'Product out of stock'
    end
  end

  class ProductNotSelected < StandardError
    def message
      'Please select product first'
    end
  end

  class CoinNotValid < StandardError
    def message
      'Coin is not valid'
    end
  end

  class ChangeCantBeProvided < StandardError
    def method
      'Change can\'t be returned. Please try again with different coins'
    end
  end
end