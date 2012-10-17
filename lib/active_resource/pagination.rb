module ActiveResource
  module Pagination
    def self.included(base)
      base.format = PagingFormatter.new(base.collection_name)
    end

    class PagedArray < Array
      attr_accessor :total_pages
      attr_accessor :current_page
    end

    # PagingFormatter expects a JSON response that looks like this (for a resource named "posts"):
    # {
    #   "total_pages": 5,
    #   "current_page": 1,
    #   "posts": [{
    #     "id": 1
    #   }]
    # }
    class PagingFormatter
      include ActiveResource::Formats::JsonFormat

      attr_accessor :collection_name

      def initialize(name)
        self.collection_name = name
      end

      def decode(json)
        meta = super(json)
        if meta.is_a?(Hash)
          list = PagedArray.new(meta[collection_name])

          list.total_pages  = meta['total_pages']
          list.current_page = meta['current_page']

          list
        else
          # unexpected result, fall back to default behavior
          meta
        end
      end
    end

  end
end
