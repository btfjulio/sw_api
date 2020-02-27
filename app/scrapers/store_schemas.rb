  
NETSHOES = {
    index: {
      link: "https://www.netshoes.com.br/suplementos?campaign=compadi",
      last_page: { 
        tag: '.last',
        block:  Proc.new { |content| content.text.strip().to_i }
      },
      products_info: {
        card_tag: '.item-card'
        link: {
          tag: '.item-card__description__product-name',
          block: Proc.new { |content| "https:#{content[:href]}?campaign=compadi" }
        },
        name: {
          tag: '.item-card__description__product-name',
          block: Proc.new { |content| content.text.strip() }
        }
        photo_url: {
          tag: '.item-card__images__image-link img',    
          block: Proc.new { |content| content[:data-src] }
        }
      }
    }
    show: {
      product_info: {
        price: { 
          tag:'.default-price', 
          block: Proc.new { |content| content.text.strip() }
        sender: { 
          tag:'.dlvr', 
          block: Proc.new { |content| content.text.strip() }
        flavor: { 
          tag: '.sku-select .item a', 
          block: Proc.new { |content| content.text.strip() }
        promo: { 
          tag: '.badge-item', 
          block: Proc.new { |content| content.text.strip() }
        seller: { 
          tag: '.product__seller_name span', 
          block: Proc.new { |content| content.text.strip() } || 'Netshoes' } 
      }
    }
  }

