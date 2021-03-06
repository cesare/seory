require 'seory'
require 'seory/page_contents'
require 'seory/page_condition/build_dsl'
require 'seory/repository'

module Seory
  module Dsl

    def describe(&block)
      @repository = Repository.new
      Descriptor.new(@repository).describe(&block)
    end

    def lookup(controller)
      @repository.lookup(controller)
    end

    class PageContentsBuilder
      def initialize(*conditions)
        @page_contents =
          if conditions.size == 1 && (block = conditions.first).is_a?(Proc)
            PageContents.new(&block)
          else
            PageContents.new(*conditions)
          end
      end

      def build!(&block)
        instance_exec(&block)

        @page_contents
      end

      def misc(name, val = nil, &block)
        @page_contents.define(name, val, &block)
      end

      def assign_reader(*names)
        @page_contents.assign_reader(*names)
      end

      Seory::CONTENTS.each do |name|
        define_method(name) {|val = nil, &block| misc(name, val, &block) }
      end
    end

    class Descriptor
      include Seory::PageCondition::BuildDsl

      def initialize(repository)
        @repository = repository
      end

      def describe(&block)
        instance_exec(&block)

        @repository
      end

      def match(*conditions, &def_builder)
        @repository << PageContentsBuilder.new(*conditions).build!(&def_builder)
      end

      def default(&def_builder)
        match(:default, &def_builder)
      end
    end
  end
end
