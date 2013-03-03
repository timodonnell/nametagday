require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include SessionMethods

def action_name() end

describe ApplicationController, :behaviour_type => :controller do
  include RSpec::Rails::ControllerExampleGroup

  before do
    stub!(:authenticate_with_http_basic).and_return nil
  end

  #This doesn't test anything!
  describe "saving info to session" do 

    before do
      @admin = FactoryGirl.create(:admin)
      login_as(@admin)
      stub!(:reset_session)
    end

    it "should save id to session" do
      session[:admin_id].should == @admin.id
    end

  end

  describe "logout_killing_session!" do
    before do
      @admin = FactoryGirl.create(:admin)
      login_as(@admin)
      stub!(:reset_session)
    end

    it 'resets the session' do
      should_receive(:reset_session)
      logout_killing_session!('admin')
    end
    it 'kills my auth_token cookie' do
      should_receive(:kill_remember_cookie!)
      logout_killing_session!('admin')
    end
    it 'nils the current user' do
      logout_killing_session!('admin')
      current_user(Admin).should be_nil
    end
    it 'kills :id session' do
      session.stub!(:[]=)
      session.should_receive(:[]=).with(:admin_id, nil).at_least(:once)
      logout_killing_session!('admin')
    end
    it 'forgets me' do
      current_user(Admin).remember_me
      current_user(Admin).remember_token.should_not be_nil
      current_user(Admin).remember_token_expires_at.should_not be_nil
      Admin.find(@admin.id).remember_token.should_not be_nil
      Admin.find(@admin.id).remember_token_expires_at.should_not be_nil
      logout_killing_session!('admin')
      Admin.find(@admin.id).remember_token.should be_nil
      Admin.find(@admin.id
                ).remember_token_expires_at.should be_nil
    end
  end

  describe "logout_keeping_session!" do
    before do
      @admin = FactoryGirl.create(:admin)
      login_as(@admin)
      stub!(:reset_session)
    end
    it 'does not reset the session' do
      should_not_receive(:reset_session)
      logout_keeping_session!('admin')
    end
    it 'kills my auth_token cookie' do
      should_receive(:kill_remember_cookie!)
      logout_keeping_session!('admin')
    end
    it 'nils the current user' do
      logout_keeping_session!('admin')
      current_user.should be_nil
    end
    it 'kills :id session' do
      session.stub!(:[]=)
      session.should_receive(:[]=).with(:admin_id, nil).at_least(:once)
      logout_keeping_session!('admin')
    end
    it 'forgets me' do
      current_user(Admin).remember_me
      current_user.remember_token.should_not be_nil
      current_user.remember_token_expires_at.should_not be_nil
      Admin.find(@admin.id).remember_token.should_not be_nil
      Admin.find(@admin.id).remember_token_expires_at.should_not be_nil
      logout_keeping_session!('admin')
      Admin.find(@admin.id).remember_token.should be_nil
      Admin.find(@admin.id).remember_token_expires_at.should be_nil
    end
  end

  #
  # Cookie Login
  #
  describe "Logging in by cookie" do
    def set_remember_token token, time
      @admin[:remember_token]            = token;
      @admin[:remember_token_expires_at] = time
      @admin.save!
    end
    before do
      @admin = FactoryGirl.create(:admin)
      @admin = Admin.first
      set_remember_token 'hello!', 5.minutes.from_now
      session[:admin_id] = nil
    end
    it 'logs in with cookie' do
      stub!(:cookies).and_return({ :admin_auth_token => 'hello!'})
      admin_logged_in?.should be_true
    end

    it 'fails cookie login with bad cookie' do
      should_receive(:cookies).at_least(:once).and_return({ :auth_token => 'i_haxxor_joo', :class => "Admin" })
      admin_logged_in?.should_not be_true
    end

    it 'fails cookie login with no cookie' do
      set_remember_token nil, nil
      should_receive(:cookies).at_least(:once).and_return({ })
      admin_logged_in?.should_not be_true
    end

    it 'fails expired cookie login' do
      set_remember_token 'hello!', 5.minutes.ago
      stub!(:cookies).and_return({ :auth_token => 'hello!' , :class => "Admin" })
      admin_logged_in?.should_not be_true
    end
  end

end
