# == Schema Information
#
# Table name: admins
#
#  id                        :integer          not null, primary key
#  adminname                  :string(255)
#  first_name                :string(255)
#  last_name                 :string(255)
#  email                     :string(255)
#  hashed_password           :string(255)
#  remember_token            :string(255)
#  enabled                   :boolean
#  remember_token_expires_at :datetime
#  created_at                :datetime
#  updated_at                :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Admin do

  it "should be able to call a Admin's full name" do
    @admin = FactoryGirl.create(:admin)
    @admin.full_name.should == "#{@admin.first_name} #{@admin.last_name}"
  end

  describe "authentication" do

    before(:each) do
      @admin= FactoryGirl.create(:admin)
    end

    it "should be able to authenticate a Admin if a created email and correct password is given" do
      Admin.authenticate(@admin.email, "password").should == @admin
    end

    it "should not authenticate a Admin if a email does not exist" do
      Admin.authenticate("fake@email.com", "password").should be_false
    end

    it "should not authenticate a Admin if a created email and incorrect password is given" do
      Admin.authenticate(@admin.email, "incorrect").should == false
    end

  end

  describe "remember_token? method" do

    it "should return false if there is no remember_token" do
      FactoryGirl.create(:admin).remember_token?.should be_false
    end

    it "should return false if there is a remember_token that has expired" do
      FactoryGirl.create(:admin, :remember_token => "abc", :remember_token_expires_at => nil ).remember_token?.should be_false
    end

    it "should return false if there is a remember_token that has expired" do
      FactoryGirl.create(:admin, :remember_token => "abc", :remember_token_expires_at => Time.now - 1).remember_token?.should be_false
    end

    it "should return ture if there is a non expired remember_token" do
      FactoryGirl.create(:admin, :remember_token => "abc", :remember_token_expires_at => Time.now + 1).remember_token?.should be_true
    end

  end

  describe "remember_me method" do

    it "should call remember_me_for with 2.weeks" do
      @admin = FactoryGirl.create(:admin)
      @admin.should_receive(:remember_me_for).with(2.weeks)
      @admin.remember_me
    end

  end

  describe "remember_me_for method" do

    it "should call remember_me_until with time from input" do
      @admin = FactoryGirl.create(:admin)
      @admin.should_receive(:remember_me_until)
      @admin.remember_me_for(2.weeks)
    end

  end

  describe "remember_me_until method" do

    it "should create a remember_token" do
      @admin = FactoryGirl.create(:admin)
      Admin.stub!(:create_token).and_return("ABC")
      lambda do
        @admin.remember_me_until(Time.now + 3000)
      end.should change(@admin, :remember_token).from(nil).to("ABC")
    end

    it "should set the expiration_date for token to designated time" do
      @admin = FactoryGirl.create(:admin)
      @time = Time.now + 3000
      lambda do
        @admin.remember_me_until(@time)
      end.should change(@admin, :remember_token_expires_at).from(nil).to(@time)
    end

  end

  describe "refresh_token method" do

    it "should create a new remember_token" do
      @admin = FactoryGirl.create(:admin, :remember_token => "abc", :remember_token_expires_at => Time.now + 30000)
      Admin.stub!(:create_token).and_return("DEF")
      lambda do
        @admin.refresh_token
      end.should change(@admin, :remember_token).from("abc").to("DEF")
    end

    it "should keep the expiration_date" do
      @time = Time.now + 3000
      @admin = FactoryGirl.create(:admin, :remember_token => "abc", :remember_token_expires_at => @time)
      lambda do
        @admin.refresh_token
      end.should_not change(@admin, :remember_token_expires_at)
    end

    it "should not create a new remember_token if expired" do
      @admin = FactoryGirl.create(:admin, :remember_token => "abc", :remember_token_expires_at => Time.now - 30000)
      lambda do
        @admin.refresh_token
      end.should_not change(@admin, :remember_token)
    end

  end

  describe "forget_me method" do

    it "should delete the remember_token" do
      @admin = FactoryGirl.create(:admin, :remember_token => "abc", :remember_token_expires_at => Time.now - 30000)
      lambda do
        @admin.forget_me
      end.should change(@admin, :remember_token).from("abc").to(nil)
    end

    it "should delete the remember_token_expires_at" do
      @time = Time.now + 3000
      @admin = FactoryGirl.create(:admin, :remember_token => "abc", :remember_token_expires_at => @time)
      lambda do
        @admin.forget_me
      end.should change(@admin, :remember_token_expires_at).from(@time).to(nil)
    end

  end

  describe "updating" do

    before(:each) do
      @mock_admin = FactoryGirl.create(:admin)
    end

    it "should allow updating of fields that are not password or email" do
      lambda do
        @mock_admin.update_attributes(:first_name => "matthew")
      end.should change(@mock_admin, :first_name).to("matthew")
    end


    it "should allow updating of password without previous_password" do
      @mock_admin.update_attributes(:password => "password", :password_confirmation => "password")
      @mock_admin.valid?.should be_true
    end

    it "should allow updating of password whith incorrect previous_password" do
      @mock_admin.update_attributes(:password => "salve", :password_confirmation => "salve", :previous_password => "markie")
      @mock_admin.valid?.should be_false
      @mock_admin.errors[:previous_password].should_not be_nil
    end

    it "should allow updating of email with correct previous_password and confirmation" do
      @mock_admin = FactoryGirl.create(:admin)
      lambda do
        @mock_admin.update_attributes(:password => "salve", :password_confirmation => "salve", :previous_password => "password")
      end.should change(@mock_admin, :hashed_password)
    end

  end

  describe "validation" do

    it "should be invalid without a first_name" do
      @admin = FactoryGirl.build(:admin, :first_name => "")
      @admin.valid?.should be_false
      @admin.errors[:first_name].should_not be_nil
    end

    it "should be invalid without a last_name" do
      @admin = FactoryGirl.build(:admin, :last_name => "")
      @admin.valid?.should be_false
      @admin.errors[:last_name].should_not be_nil
    end


    it "should be invalid without a email" do
      @admin = FactoryGirl.build(:admin, :email => "")
      @admin.valid?.should be_false
      @admin.errors[:email].should_not be_nil
    end

    it "should be invalid without a password" do
      @admin = FactoryGirl.build(:admin, :password => "")
      @admin.valid?.should be_false
      @admin.errors[:password].should_not be_nil
    end

    it "should be invalid with a first_name greater then 50" do
      @admin = FactoryGirl.build(:admin, :first_name => "c" * 51)
      @admin.valid?.should be_false
      @admin.errors[:first_name].should_not be_nil
    end

    it "should be invalid with a last_name greater then 50" do
      @admin = FactoryGirl.build(:admin, :last_name => "c" * 51)
      @admin.valid?.should be_false
      @admin.errors[:last_name].should_not be_nil
    end

    it "should be invalid with a email greater then 255" do
      @admin = FactoryGirl.build(:admin, :email => "c" * 256)
      @admin.valid?.should be_false
      @admin.errors[:email].should_not be_nil
    end

    it "should be invalid without a unique email" do
      #Validate uniqueness must hit the database
      @mock_admin = FactoryGirl.create(:admin)
      lambda do
        FactoryGirl.create(:admin, :email => @mock_admin.email)
      end.should raise_error(ActiveRecord::RecordInvalid)
    end

  end

end
