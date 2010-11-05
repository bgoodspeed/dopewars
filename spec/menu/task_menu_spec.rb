# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec/rspec_helper'

describe TaskMenu do
  include DomainMocks

  before(:each) do
    @game = mock_game
    @stat_action = StatLineInfoMenuAction.new(@game)
    @item_action = UseItemMenuAction.new(@game)
    @selections = Selections.new
    
    @task_menu = TaskMenu.new(@game, [
        @stat_action,
        @item_action,
      ])
  end

  def expecting_draw
    m = mock("action")
    m.should_receive(:draw)
    m
  end

  it "should delegate drawing to actions" do
    TaskMenu.new(@game, [expecting_draw, expecting_draw]).draw(nil, nil,nil)
  end

  it "should know its size" do
    @task_menu.size.should == 2
  end

  it "should know its size at given paths" do
    @task_menu.size_at([],nil).should == 2
    @task_menu.size_at([0],nil).should == 2
    @task_menu.size_at([0,0],selections_with_hero).should == 4
    @task_menu.size_at([1,0],nil).should == 1
    @task_menu.size_at([1,0,0],nil).should == 2
  end

  it "should know the element at a cursor index" do
    @task_menu.element_at(0, nil).should be_an_instance_of StatLineInfoMenuAction
    @task_menu.element_at(1, nil).should be_an_instance_of UseItemMenuAction
  end

  it "should be able to navigate a given path" do
    @task_menu.navigate_path([]).should == @task_menu
    @task_menu.navigate_path([0]).should == @stat_action.element_at(0, nil)
    @task_menu.navigate_path([0,1]).should == @stat_action.element_at(1,nil)
    @task_menu.navigate_path([1]).should == @item_action.element_at(0,nil)
    @task_menu.navigate_path([1,2]).should == @item_action.element_at(1,nil)
  end

  it "should be able to get a name for a given path plus current cursor -- root level" do
    @task_menu.element_name_at([],0,nil).should == @stat_action.name
    @task_menu.element_name_at([],1,nil).should == @item_action.name
  end

  def selections_with_hero
    @selections << hero("bob")
    @selections
  end

  it "should be able to get a name for a given path plus current cursor -- inside stat task" do
    @task_menu.element_name_at([0],0,nil).should == "person a"
    @task_menu.element_name_at([0],1,nil).should == "person b"
    @task_menu.element_name_at([0, 0],0,selections_with_hero).should == "HP: 10/10"
  end

  it "should be able to get a list of elements for a a given path and selections" do
    @task_menu.element_names_at([       ], nil).should == [@stat_action.name, @item_action.name]
    @task_menu.element_names_at([0      ], nil).should == ["person a", "person b"]
    @task_menu.element_names_at([0, 0   ], selections_with_hero).should == ["HP: 10/10", "MP: 1/1", "EXP: 0", "LVP: 0"]
    @task_menu.element_names_at([1, 0   ], nil).should == ["item 1"]
    @task_menu.element_names_at([1, 0, 0], nil).should == ["person a", "person b"]
  end

  it "should be able to determine if any dependencies are matched" do
    @task_menu.any_satisfiable_and_selected?(@selections).should be_false
  end
end

