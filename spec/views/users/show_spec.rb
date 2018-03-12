require 'rails_helper'

RSpec.describe "users/show" do
  it "Doesn't render empty avatar" do
    assign :user, create(:user, avatar: nil)
    render
    expect(rendered).not_to have_selector('.avatar')
  end

  it "Doesn't render empty about" do
    assign :user, create(:user, about: nil)
    render
    expect(rendered).not_to have_selector('.about')
  end
end
