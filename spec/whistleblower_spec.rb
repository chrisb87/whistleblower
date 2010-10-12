require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/example_alert'

def stubbed_alert(raised=false, passing=true)
  alert = ExampleAlert
  [:db, :on_raised, :on_sustained, :on_resolved].each do |method|
    alert.stub!(method).and_return(nil)
  end
  alert.stub!(:uuid).and_return('2cb94af9-1ebd-4d06-ab2e-d7de75c6e7f9')
  alert.stub!(:raised?).and_return(raised)
  alert.stub!(:foo).and_return(999999) if not passing
  return alert
end

describe Whistleblower::Alert do
  describe ".validate" do
    context "before an alert has been raised" do
      it "should call all validations" do
        alert = stubbed_alert(raised=false)
        alert.should_receive(:validate_foo_less_than_or_equal_to_1000).and_return(nil)
        alert.should_receive(:validate_basic_math).and_return(nil)
        alert.validate
      end

      context "with all validations passing" do
        it "should not call any methods relating to raising, sustaining resolving" do
          alert = stubbed_alert(raised=false, passing=true)
          [:raise_alert, :on_raised, :sustain_alert, :on_sustained, :resolve_alert, :on_resolved].each do |method|
            alert.should_not_receive(method)
          end
          alert.validate
        end
      end
      
      context "with one validation failing" do
        it "should call raise_alert and on_raised" do
          alert = stubbed_alert(raised=false, passing=false)
          [:raise_alert, :on_raised].each do |method|
            alert.should_receive(method).and_return(nil)
          end
          [:sustain_alert, :on_sustained, :resolve_alert, :on_resolved].each do |method|
            alert.should_not_receive(method)
          end
          alert.validate
        end
      end

    end

    context "after an alert has been raised" do
      context "with all validations passing" do
        it "should call resolve_alert and on_resolved" do
          alert = stubbed_alert(raised=true, passing=true)
          [:resolve_alert, :on_resolved].each do |method|
            alert.should_receive(method).and_return(nil)
          end
          [:raise_alert, :on_raised, :sustain_alert, :on_sustained].each do |method|
            alert.should_not_receive(method)
          end
          alert.validate
        end
      end
    
      context "with one validation failing" do
        it "should call sustain_alert and on_sustained" do
          alert = stubbed_alert(raised=true, passing=false)
          [:sustain_alert, :on_sustained].each do |method|
            alert.should_receive(method).and_return(nil)
          end
          [:raise_alert, :on_raised, :resolve_alert, :on_resolved].each do |method|
            alert.should_not_receive(method)
          end
          alert.validate
        end
      end
    end

  end

end

