require 'rails_helper'

describe ActiveAdmin::Share, focus: true do
  describe ActiveAdmin::Share::DSL do
    let(:dsl_classes) { [ ActiveAdmin::DSL, ActiveAdmin::ResourceDSL, ActiveAdmin::PageDSL, ActiveAdmin::Filters::DSL ] }

    context "provides the same methods like DSL, ResourceDSL, PageDSL and Filters::DSL" do
      let(:dsl) { ActiveAdmin::Share::DSL.new }
      let(:args) { [:some, :args] }
      let(:block) { proc { } }

      it "should response to each method of all DSL classes" do
        dsl.dsl_methods.each do |method|
          expect(dsl).to respond_to(method)
        end
      end

      it "should store the args and block under the share and method name" do
        expect(dsl.store).to receive(:add).with(:index, [[{as: :grid}], block])
        dsl.index(as: :grid, &block)
      end

      describe ".dsl_methods" do
        it "should return the methods of all DSL classes" do
          dsl_classes.each do |dsl_class|
            [:instance_methods, :private_instance_methods, :protected_instance_methods].each do |type|
              expect(dsl_class).to receive(type).and_return(["#{dsl_class.name}: #{type}", "superclass #{type}"])
            end
          end
          expect(Object).to receive(:instance_methods).once.and_return(["superclass instance_methods"])
          expect(Object).to receive(:private_instance_methods).once.and_return(["superclass private_instance_methods"])
          expect(Object).to receive(:protected_instance_methods).once.and_return(["superclass protected_instance_methods"])

          expect(dsl.dsl_methods).to eq ["ActiveAdmin::DSL: instance_methods", "ActiveAdmin::ResourceDSL: instance_methods",
                                         "ActiveAdmin::PageDSL: instance_methods", "ActiveAdmin::Filters::DSL: instance_methods",
                                         "ActiveAdmin::DSL: private_instance_methods", "ActiveAdmin::ResourceDSL: private_instance_methods",
                                         "ActiveAdmin::PageDSL: private_instance_methods", "ActiveAdmin::Filters::DSL: private_instance_methods",
                                         "ActiveAdmin::DSL: protected_instance_methods", "ActiveAdmin::ResourceDSL: protected_instance_methods",
                                         "ActiveAdmin::PageDSL: protected_instance_methods", "ActiveAdmin::Filters::DSL: protected_instance_methods"]
        end
      end

      describe ActiveAdmin::Share::DSL::Store do
        let(:store) { ActiveAdmin::Share::DSL::Store.new }

        it "should respond to entries" do
          expect(store).to respond_to :entries
          expect(store.entries).to be_a Hash
          expect(store.entries[:a_key]).to be_a Hash
        end

        it "should store values in a 2 dimention matrix" do
          store.add :key1, :key2, :value
          expect(store.entries).to eq key1: { key2: :value }
        end

        it "should fetch the value of 2 keys" do
          store.add :key1, :key2, :value
          expect(store.fetch(:key1, :key2)).to eq :value
        end
      end
    end
  end
end
