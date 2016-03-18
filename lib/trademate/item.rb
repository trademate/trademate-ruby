module Trademate
  class Item < Base
    attr_accessible :asin, :dream_robot, :dream_robot_stock_id, :dream_robot_stock_number, :ean, :extra, :external_number,
                    :external_stock_quantity, :inactive, :master, :show_master,
                    :info, :item_group_id, :initial_quantity, :minimum_purchase_quantity,
                    :name, :name_de, :no_auto_explode, :not_asset_accountable, :purchase_price,
                    :purchase_quantity_unit_id, :stock_quantity_unit_id, :recommended_retail_price, :sales_price,
                    :sales_quantity_unit_id, :slug, :subtitle, :traceable, :vat_type, :shop, :weight, :sku,
                    :sales_price_net_mode, :purchase_price_gross_mode, :number, :width, :height, :depth, :dimensions, :dimensions_in_cm,
                    :purchase_quantity_unit_conversion_factor_numerator, :purchase_quantity_unit_conversion_factor_denominator,
                    :sales_quantity_unit_conversion_factor_numerator, :sales_quantity_unit_conversion_factor_denominator,
                    :purchase_container_quantity, :shipping_method, :bom, :manufacturer_id

    attr_readable :margin, :full_stock_quantity, :full_planning_quantity, :full_incoming_quantity, :full_outgoing_quantity,
                  :full_avg_stock_value, :purchase_quantity_unit_conversion_factor, :sales_quantity_unit_conversion_factor,
                  :margin_rate

    updatable
    destroyable
  end
end
