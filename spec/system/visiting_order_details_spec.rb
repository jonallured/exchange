require 'rails_helper'

RSpec.describe 'visit order details', type: :system do
  let(:order) { Fabricate(:order) }
  before do
    stub_request(:get, "#{Rails.application.config_for(:gravity)[:api_v1_root]}/user/#{order.buyer_id}")
      .to_return(status: 200, body: {}.to_json, headers: {})

    stub_request(:get, "#{Rails.application.config_for(:gravity)[:api_v1_root]}/partner/#{order.seller_id}/all")
      .to_return(status: 200, body: {}.to_json, headers: {})
    allow_any_instance_of(ApplicationController).to receive(:require_artsy_authentication)
  end

  it 'renders order details page', js: true do
    visit '/admin'

    page_title_selector = 'h2#page_title'

    expect(page).to have_selector(page_title_selector)

    row_selector = 'td.col.col-code'

    expect(page).to_not have_selector(row_selector)

    tab_selector = 'li.scope.all'
    within tab_selector do
      click_link 'All'
    end

    within row_selector do
      click_link order.code
    end

    expect(page).to have_selector(page_title_selector)

    within page_title_selector do
      expect(page).to have_content("Order #{order.id}")
    end
  end

  context 'for an inquiry order' do
    let(:order) { Fabricate(:order, impulse_conversation_id: '123') }

    it 'renders a link to Impulse conversation' do
      visit "/admin/orders/#{order.id}"
      expect(page).to have_link('123', href: 'https://impulse-staging.artsy.net/admin/conversations/123')
    end
  end
end
