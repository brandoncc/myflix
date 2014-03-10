Fabricator(:payment) do
  user { Fabricate(:user) }
  invoice_id { 'in_iyv98126fe09812eo' }
  charge_id { 'ch_ioyvw08623r8' }
  amount { (1..10000).to_a.sample }
  successful true
end
