class ReceiptsController < ApplicationController
  before_action :set_receipt, only: %i[
    show update destroy receipt_preview receipt_pdf static_pdf
  ]

  skip_before_action :authenticate_request, only: [:receipt_preview, :receipt_pdf , :static_pdf]

  # GET /receipts
  def index
    @receipts = Receipt.order(created_at: :desc)
    render json: @receipts
  end

  # GET /receipts/:id
  def show
    render json: @receipt
  end















  def receipt_preview
    @text = "Hello World"  # ข้อความที่จะแสดงใน preview
    render html: "<h1>#{@text}</h1>".html_safe
  end









  # GET /receipts/:id/receipt_pdf
  def receipt_pdf
    # สร้าง HTML จาก template
    html = render_to_string(
      template: "pdf_templates/receipt_pdf",  # path จาก app/views
      layout: false,
      locals: { receipt: @receipt }           # ถ้าต้องการใช้ locals
    )

    # สร้าง PDF
    pdf = WickedPdf.new.pdf_from_string(html)

    # ส่ง PDF กลับ
    send_data pdf,
              filename: "receipt_#{@receipt.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end




# def static_pdf
#   html_file = Rails.root.join("lib/pdf_templates/static_receipt.html")
#   html = File.read(html_file)

#   pdf = WickedPdf.new.pdf_from_string(html)

#   send_data pdf,
#             filename: "static_receipt.pdf",
#             type: "application/pdf",
#             disposition: "inline"
# end





  def static_pdf
    # render template เป็น string
    html = render_to_string(template: "pdf_templates/static_receipt", layout: false)

    pdf = WickedPdf.new.pdf_from_string(html)

    send_data pdf,
              filename: "static_receipt.pdf",
              type: "application/pdf",
              disposition: "inline"
  end













  # POST /receipts
  def create
    @receipt = Receipt.new(receipt_params)

    if @receipt.save
      render json: @receipt, status: :created
    else
      render json: @receipt.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /receipts/:id
  def update
    if @receipt.update(receipt_params)
      render json: @receipt
    else
      render json: @receipt.errors, status: :unprocessable_entity
    end
  end

  # DELETE /receipts/:id
  def destroy
    @receipt.destroy
  end

  private

  def set_receipt
    @receipt = Receipt.find(params[:id])
  end

  def receipt_params
    params.require(:receipt)
          .permit(:user_id, :receipt_no, :total_summary, :total_amount)
  end
end
