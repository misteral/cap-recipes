God::Contacts::Email.defaults do |d|
  d.from_email = 'god@localhost'
  d.from_name = 'god'
  d.delivery_method = :sendmail
  d.to_email = 'root@localhost'
end

God.contact(:email) do |c|
  c.name      = 'localhost'
  c.to_email  = "root@localhost"
end
