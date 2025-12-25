class Receipt < ApplicationRecord
  belongs_to :user
  has_many :receipt_items, dependent: :destroy

    def self.generate_receipt_no
    today = Time.zone.today
    date_str = today.strftime("%Y%m%d")

    count_today = where(
      created_at: today.beginning_of_day..today.end_of_day
    ).count + 1

    format("R%s-%04d", date_str, count_today)
  end

  def as_json_with_items
    {
      id: id,
      receipt_no: receipt_no,
      total_summary: total_summary,
      total_amount: total_amount,
      created_at: created_at,
      items: receipt_items.includes(:sku_master).map do |ri|
        {
          id: ri.id,
          sku_master_id: ri.sku_master_id,
          sku_name: ri.sku_master.name,
          quantity: ri.quantity,
          price: ri.price
        }
      end
    }
  end


  def self.generate_receipt_no
    today = Time.zone.today
    date_str = today.strftime("%Y%m%d")

    count_today = where(
      created_at: today.beginning_of_day..today.end_of_day
    ).count + 1

    format("R%s-%04d", date_str, count_today)
  end





  









end
