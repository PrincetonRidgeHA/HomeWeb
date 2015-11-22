# configure :production, :development, :test do
configure :production do
	if(ENV['DATABASE_URL'])
		db = URI.parse(ENV['DATABASE_URL'])
	else
		db = URI.parse('postgres://localhost/mydb')
	end

	ActiveRecord::Base.establish_connection(
			:adapter  => 'postgresql',
			:host     => db.host,
			:username => db.user,
			:password => db.password,
			:database => db.path[1..-1],
			:encoding => 'utf8'
	)
end
configure :development, :test do
	ActiveRecord::Base.establish_connection(
			:adapter  => 'postgresql',
			:host     => 'ec2-54-163-228-188.compute-1.amazonaws.com',
			:username => 'zozzuejiukpbns',
			:password => 'nbyuQqfpXvlFb178HXvqaDTuPP',
			:database => 'ddbvvogf4fjltn',
			:encoding => 'utf8'
	)
end