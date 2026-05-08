class OrdersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  before_action :set_order, only: %i[ show edit update destroy ]

  # GET /orders or /orders.json
  def index
    @orders = Order.with_attached_cake_image.order(order_date: :desc, created_at: :desc)

    # Filtering
    if params[:store_name].present?
      @orders = @orders.where(store_name: params[:store_name])
    end

    if params[:start_date].present?
      @orders = @orders.where("order_date >= ?", params[:start_date])
    end

    if params[:end_date].present?
      @orders = @orders.where("order_date <= ?", params[:end_date])
    end

    # Grouping
    @group_by = params[:group_by] || "store"
    if @group_by == "date"
      @grouped_orders = @orders.group_by { |o| o.order_date.to_s }
    else
      @grouped_orders = @orders.group_by(&:store_name)
    end
  end


  # GET /orders/1 or /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders or /orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1 or /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: "Order was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1 or /orders/1.json
  def destroy
    @order.destroy!

    respond_to do |format|
      format.html { redirect_to orders_path, notice: "Order was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.expect(order: [ :order_number, :store_name, :manager_name, :order_date, :pickup_date, :customer_name, :cake_description, :cake_image ])
    end
end
