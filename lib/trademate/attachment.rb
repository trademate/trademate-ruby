module Trademate
  class Attachment < Base
    attr_accessible :filename, :data, :attachment_type, :info, :metadata, :report_name, :shared, :shop, :pos_order
    attr_readable :uuid, :url, :relative_url
    protected :data, :data=
    
    updatable
    destroyable
    
    def item_id=(item_id)
      extra_params['item_id'] = item_id
    end
    
    def item_id
      extra_params['item_id']
    end
    
    def contact_id=(contact_id)
      extra_params['contact_id'] = contact_id
    end
    
    def contact_id
      extra_params['contact_id']
    end
    
    def content_type
      data && data['content_type']
    end
    
    def content_type=(content_type)
      data && data['content_type'] = content_type
    end
    
    def upload=(file)
      # TODO: clear data, set content type from file
      self.data ||= {}
      data['base64'] = Base64.strict_encode64(File.binread(file)) 
      data['filename'] = File.basename(file)
    end
    
  end
end
