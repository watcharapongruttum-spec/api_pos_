class User < ApplicationRecord
  # =========================
  # AUTH
  # =========================
  has_secure_password

  # =========================
  # ASSOCIATIONS
  # =========================
  has_one :cart, dependent: :destroy
  has_many :receipts, dependent: :destroy

  # =========================
  # CALLBACKS
  # =========================
  after_create :create_cart_for_user

  # =========================
  # VALIDATIONS
  # =========================
  validates :role,
            inclusion: { in: %w[admin user], message: "%{value} is not a valid role" }

  validates :username,
            presence: true,
            uniqueness: true

  validates :password,
            presence: true,
            length: { minimum: 6 },
            on: :create

  # =========================
  # SERIALIZER
  # =========================
  def self.respond_to_json(users)
    users.map do |user|
      {
        id: user.id,
        username: user.username,
        name: user.name,
        role: user.role
      }
    end
  end

  # =========================
  # QUERY (ActiveRecord ONLY)
  # =========================

  # ใช้แทน all_sql (ปลอดภัย + เร็ว)
  def self.list_basic
    select(:id, :username, :name, :role)
  end

  def self.search(keyword)
    return list_basic if keyword.blank?

    safe = sanitize_sql_like(keyword)

    where(
      "username ILIKE :q OR name ILIKE :q",
      q: "%#{safe}%"
    ).select(:id, :username, :name, :role)
  end

  # =========================
  # OPTIONAL: RAW SQL (ถ้าจำเป็นจริง ๆ)
  # =========================
  # ❌ ห้าม cache connection
  # ❌ ห้าม close connection เอง
  def self.search_sql(keyword)
    safe = sanitize_sql_like(keyword.to_s)

    ActiveRecord::Base.connection_pool.with_connection do |conn|
      result = conn.exec_query(
        <<~SQL,
          SELECT id, username, name, role
          FROM users
          WHERE username ILIKE $1
             OR name ILIKE $1
        SQL
        "UserSearch",
        [[nil, "%#{safe}%"]]
      )

      result.rows.map do |row|
        instantiate(result.columns.zip(row).to_h)
      end
    end
  end

  # =========================
  # PRIVATE
  # =========================
  private

  def create_cart_for_user
    create_cart!(
      total_summary: 0,
      total_amount: 0,
      status: "active"
    )
  end
end
