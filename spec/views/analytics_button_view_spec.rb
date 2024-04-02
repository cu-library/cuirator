# spec/views/example_view_spec.rb
require 'rails_helper'

RSpec.describe "hyrax/file_sets/show", type: :view do
  it "should NOT display the analytics button" do
    file_set = FactoryBot.create(:file_set, title: ["Test File Set Title"])

    presenter = instance_double("Hyrax::FileSetPresenter", page_title: file_set.title)
 
    # Stub any other necessary methods or attributes for presenter

    assign(:presenter, @presenter.page_title) # Assign the presenter to @presenter
    render
    expect(rendered).not_to have_button("Analytics") # Check if the button is present
  end
end
