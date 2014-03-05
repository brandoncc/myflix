require 'spec_helper'

describe Payment do
  it { should belong_to(:user) }
  it { should validate_presence_of(:charge_id) }
  it { should validate_presence_of(:invoice_id) }
  it { should validate_presence_of(:amount) }
end
