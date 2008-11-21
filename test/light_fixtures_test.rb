require 'test/unit'
require File.join(File.dirname(__FILE__), '../../../../config/environment')

class CreateCars < ActiveRecord::Migration
  def self.up
    create_table :cars do |t|
      t.string 'make', 'model', 'color', 'owner'
    end
  end

  def self.down
    drop_table :cars
  end
end

class Car < ActiveRecord::Base 

end

class LightFixturesTest < Test::Unit::TestCase
  def setup
    CreateCars.up
    @heavy_fixtures = Fixtures.create_fixtures('fixtures', 'cars')
  end
  
  def teardown
    CreateCars.down
  end
  
  def test_that_it_loads_nine_fixtures
    assert @heavy_fixtures.length, 9
  end
  
  def test_that_it_pattern_matches_on_fixture_name 
    assert Car.exists?({:owner => 'joe'})
    assert Car.exists?({:make => 'chevy'})
    assert Car.exists?({:model => 'malibu'})
  end
  
  def test_that_it_can_propigate_values_though_grouped_fixtures
    Car.find(:all, :conditions => {:owner => 'freddy'}).each do |car|
      assert car.make, 'ford'
      assert car.make, 'red'
    end
  end
  
  def test_that_it_can_propigate_values_without_patterns
    Car.find(:all, :conditions => {:owner => 'jeddi'}).each do |car|
      assert car.color, 'blue'
      assert car.make, 'chevy'
    end
  end
   
end
