require 'rails_helper'

describe Invitation do
  it { should belong_to(:user) }
  it_behaves_like 'tokenable' do
    let(:object) { Fabricate(:invitation) }
  end
end