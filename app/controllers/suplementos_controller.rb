class SuplementosController < ApplicationController
  layout 'suplementos_layout'
  before_action :get_stores, only: [:index]
  before_action :get_filters, only: [:index]
  before_action :get_sellers, only: [:index]

  def index
    @suplementos = Suplemento.includes(:brand, :store).calc_discount
    apply_filters(params[:filters])
    @suplementos = @suplementos.where(store_id: params[:store]) if params[:store].present?
    @suplementos = @suplementos.seller_search(params[:seller]) if params[:seller].present?
    @suplementos = @suplementos.name_search(params[:name]) if params[:name].present?
    @suplementos = @suplementos.page(params[:page]).per(28)
  end

  def create_bitlink
    client = Bitly.client
    @suplemento = params[:suplemento]
    @link = params[:link]
    choice = params[:choice]&.first
    @link = change_cupom(@link, params[:cupom]) if params[:cupom].present?
    @link = @link.gsub('lojacorpoperfeito', choice) if choice.present?
    @link = client.shorten(@link).short_url
  end

  def change_cupom(link, cupom)
    if link.match?(/lojacorpoperfeito\.com/)
      @link.gsub(/vp=.+/, "vp=#{cupom}")
    elsif link.match?(/netshoes\.com/)
      # it depends on already having a campaign in link
      @link.gsub(/(?<=campaign\=).*/, "#{cupom}")
    else
      @link
    end
  end

  private

  def get_stores
    @stores = Store.joins(:suplementos).distinct.order(:name)
  end

  def get_sellers
    @sellers = Suplemento.order(:seller).pluck(:seller).uniq
  end

  def apply_filters(filters)
    if filters
      @suplementos = @suplementos.order(price_cents: :asc) if filters.include?('price') || !filters.include?('average')
      @suplementos = @suplementos.where('price_cents < average').order('average') if filters.include?('average')
      @suplementos = @suplementos.where("promo <> ''") if filters.include?('cupom')
      @suplementos = @suplementos.where(supershipping: true) if filters.include?('frete')
      @suplementos = @suplementos.where(combo: 'true') if filters.include?('combo')
    else
      @suplementos = @suplementos.order(price_cents: :asc)
    end
  end

  def get_filters
    @filters = %w[combo frete cupom preço average]
  end

  def suplemento_params
    params.require(:suplemento).permit!
  end
end
