Fabricator(:invitation) do
 user
 email_invited { 'test@example.com'} 
 name {'someone'}
 message {'Please join MyFlix'}
end