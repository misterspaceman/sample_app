require 'spec_helper'
describe "UserPages" do
  subject { page }

  describe "signup" do
    before { visit signup_path }
    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_content('error') }

        it { should have_selector('li', text: "* Email can't be blank") }
        it { should have_selector('li', text: "* Email is invalid") }
        it { should have_selector('li', text: "* Name can't be blank") }
        it { should have_selector('li', text: "* Password is too short (minimum is 6 characters") }
        it { should have_selector('li', text: "* Password can't be blank") }
      end

      describe "after submitting mis-matching passwords" do
        before do
          fill_in "Password", with: "something"
          fill_in "Confirmation", with: "something else"
          click_button submit
        end

        it { should have_selector('li', text: "* Password confirmation doesn't match Password")}
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name", 	with: "Example User"
        fill_in "Email",	with: "user@example.com"
        fill_in "Password", with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome')}

      end

    end

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end


  describe "signin" do

    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-error') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    describe "with valid information" do
    	let(:user) { FactoryGirl.create(:user) }
    	before do
    		fill_in "Email", with: user.email.upcase
    		fill_in "Password", with: user.password
    		click_button "Sign in"
    	end

    	it { should have_title(user.name) }
    	it { should have_link('Profile', href: user_path(user)) }
    	it { should have_link('Sign out', href: signout_path) }
    	it { should_not have_link('Sign in', href: signin_path) }

    	describe "followed by signout" do
    		before { click_link "Sign out" }
    		it { should have_link('Sign in') }
    	end
    end
  end
end
