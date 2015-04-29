require 'rails_helper'

describe Invitation do
  it { should belong_to(:user) }
end