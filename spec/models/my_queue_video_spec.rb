require 'rails_helper'

describe MyQueueVideo do  
  it { should belong_to(:user)}
  it { should belong_to(:video)}
  it { should validate_numericality_of(:position).only_integer}
end