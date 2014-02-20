require 'spec_helper'

describe Invite do
  it { should belong_to(:creator) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:message) }

  it_behaves_like 'tokenable' do
    let(:object) { Fabricate(:invite) }
  end
end
