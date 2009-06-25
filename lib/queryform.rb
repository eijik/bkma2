# uri/queryform.rb -- query form container, serializer, deserializer for URI
# Copyright (C) 2007  Tociyuki MIZUTANI
# This is a free software.
# You can distribute/modify this under the terms of the same as Ruby.

require 'uri'
require 'delegate'

module URI
  
  class QueryForm < DelegateClass(Hash).instance_eval {
      private :__getobj__, :__setobj__
      [ :dup, :clone, :clear, :reject, :reject!, :delete_if,
        :merge, :merge!, :replace, :update, :to_s, :invert
      ].each {|method| remove_method method }
      self
    }
    
    VERSION = "0.04"
    
    attr_accessor :separator
    attr_accessor :unsafe
    
    def self.[](*arg) new(Hash[*arg]) end
    
    def self.parse(s)
      s.split(/[&;]/).inject(self.new) {|qform, pair|
        key, value = pair.split(/=/, 2).collect {|v| URI.unescape(v) }
        (qform[key] ||= []) << value
        qform
      }
    end
    
    def initialize(hash = nil)
      super(hash || {})
      @separator = '&' # traditional
      # @separator = ';' # modern
      @unsafe = /[^\w\-.*\/:\x20]/n
    end
    
    def queries
      __getobj__
    end
    
    private :queries
    
    def queries=(x)
      __setobj__(x)
    end
    
    protected :queries= # use only clone/dup
    
    def query_escape(s, re = @unsafe)
      URI.escape(s.to_s, re).gsub(/\x20/, '+')
    end
    
    def to_s
      queries.collect {|k, v|
        v = [v] unless v.respond_to?(:each_index)
        v.collect {|e| query_escape(k) + "=" + query_escape(e) }
      }.flatten.join(separator)
    end
    
    alias :to_str :to_s
    
    def clone
      obj = super
      obj.queries = queries.clone
      obj
    end
    
    def dup
      obj = super
      obj.queries = queries.dup
      obj
    end
    
    def freeze
      queries.freeze
      super
    end
    
    def reject(&p)
      self.class.new(queries.reject(&p))
    end
    
    def reject!(&p)
      queries.reject!(&p) and self
    end
    
    def merge(other, &p)
      self.class.new(queries.merge(other, &p))
    end
    
    [:clear, :delete_if, :merge!, :replace, :update].each do |method|
      module_eval <<-END_DEF
        def #{method}(*a, &p)
          queries.#{method}(*a, &p)
          self
        end
      END_DEF
    end
    
  end
end

__END__
=begin

== SYNOPSYS

  require 'uri'
  require 'uri/queryform'
  
  # create a URI::QueryForm object from a pair list.
  qform = URI::QueryForm[
    'key0', 'value0', 'key1', ['value1'], 'key2', ['value2-0', 'value2-1']
  ]
  # create a URI::QueryForm object for a hash. (same above)
  qform = URI::QueryForm.new({
    'key0' => 'value0', 'key1' => ['value1'], 'key2'=> ['value2-0', 'value2-1']
  })
  # store/fetch/replace/delete and others as same as Hash except for invert.
  qform['key'] = 'new value'
  qform['key'] = ['new value']
  qform['key'] << 'other value'
  qform.delete('key')
  qform.has_key?('key')
  # URI object accept qform directly
  uri = URI.parse('http://anywhere.jp/')
  uri.query = qform
  uri.query['key'] = ['new value', 'new value']
  puts uri
  # create URI object with URI::QueryForm
  uri = URI::HTTP.build(
    :host => 'anywhere.jp',
    :path => '/search',
    :query => URI::QueryForm[
      'word' => 'hoge'
    ]
  )
  puts uri
  # escape and serialize URI::QueryForm object automatically when URI.to_s
  response = uri.open {|f| f.read }
  # deserialize and unescape query
  qform = URI::QueryForm(uri.query)
  qform.each {|k, v| puts "#{k} = #{v}" }
  
  # attribute accessors
  qform.separator = ';' # modern separator
  qform.unsafe = /[^\w]/ # 
=end
