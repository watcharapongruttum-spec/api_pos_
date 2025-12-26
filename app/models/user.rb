class User < ApplicationRecord
    has_secure_password

    has_one :cart, dependent: :destroy
    has_many :receipts, dependent: :destroy

    
    after_create :create_cart_for_user



    validates :role, inclusion: { in: %w(admin user), message: "%{value} is not a valid role" }
    validates :username, presence: true, uniqueness: true
    validates :password, presence: true, length: { minimum: 6 }, on: :create



    def self.respon_to_json_user(users = [])
        users.map do |user|
        {
            id: user.id,
            username: user.username,
            name: user.name,
            role: user.role
        }
        end
    end



  def self.conn
    @conn ||= ActiveRecord::Base.connection
  end





  def self.all_sql(select_cols: %w(id username name role))
    sql = "SELECT #{select_cols.map { |c| conn.quote_column_name(c) }.join(', ')} FROM users"
    result = conn.exec_query(sql)

    result.rows.map do |row|
      row_hash = result.columns.zip(row).to_h
      instantiate(row_hash)
    end
  end









  
    def self.search(keyword)
        if keyword.present?
          where("username ILIKE ? OR name ILIKE ?", "%#{keyword}%", "%#{keyword}%")
        else
          all
        end
    end







  def self.search_sql(params)

    keyword = params[:keyword] if keyword.is_a?(Hash)

    conn = ActiveRecord::Base.connection
    safe = ActiveRecord::Base.sanitize_sql_like(keyword.to_s)

    result = conn.execute(%{
      SELECT id, username, name, role
      FROM users
      WHERE username ILIKE '%#{safe}%'
        OR name ILIKE '%#{safe}%'
    }).to_a

    result.map { |row| instantiate(row) }
  end






























    private

    def create_cart_for_user
    create_cart!(total_summary: 0, total_amount: 0, status: "active")
    end









end


