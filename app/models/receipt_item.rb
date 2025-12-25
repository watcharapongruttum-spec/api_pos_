class ReceiptItem < ApplicationRecord
  belongs_to :receipt
  belongs_to :sku_master


  def self.by_receipt(receipt_id)
    where(receipt_id: receipt_id)
  end

end
