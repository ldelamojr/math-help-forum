require "sinatra/base"
require "pg"
require "bcrypt"
require "pry"
require "sinatra"

#@@db.exec_params(<<-SQL, [session["user_id"]])
#				select * from users where id = $1
#				SQL

module Forum
	class Server < Sinatra::Base
	
		enable :sessions
#request.referer

		@@db ||= PG.connect(dbname: "forum")

		def current_user 
			if session["user_id"]
				@current_user ||= @@db.exec_params(<<-SQL, [session["user_id"]]).first
				select * from users where id = $1
				SQL
				#logged in
			else
				#not logged in
			end
		end

		get "/" do
			#choose a way to sort topics
			#provide link to create new topic

			erb :index			
		end


		get "/login" do
			@non_secure_page = true
			@user = current_user
			erb :login
		end


		post "/login" do

			@user = @@db.exec_params("select * from users where user_name = $1", [params[:user_name]]).first
			
			if @user
				if BCrypt::Password.new(@user["password_digest"]) == params[:password] 
					session["user_id"] = @user["id"]
					redirect("/topics")
				else
					@error = "Invalid Password"
					redirect "/login?error=#{@error}"
				end
			else
				@error = "Invalid Username"
				redirect "/login?error=#{@error}"
			end

		end


		get "/signup" do
			@non_secure_page = true
			# DISPLAY most discussed question via the query below
			# @top_topic = @@db.exec("select topic from question order by num_of_questions limit 1")
			erb :signup
		end


		post "/signup" do
			encrypted_password = BCrypt::Password.create(params[:password])

			users = @@db.exec_params(<<-SQL, [params[:user_name],encrypted_password, 0])
				insert into users (user_name, password_digest, num_of_topics_created) values ($1, $2, $3) returning id;
				SQL

			session["user_id"] = users.first["id"]

			redirect("/topics")
		end


		get "/logout" do
			session["user_id"] = false
			redirect "/login"
		end



############################################################################
																#
																#
		get "/topics" do						#
			@non_secure_page = true#######
			#shows links to all topics arranged by either number of comments or upvotes
			@topics = @@db.exec("Select * from topics")
				# binding.pry
			erb :topics
		end

		post "/topics" do
			#sends info from form to server
			new_topic = params["new_topic"]
			new_question = params["new_question"]

			if ENV["RACK_ENV"] == 'production'
				conn = PG.connect(
					dbname: ENV["POSTGRES_DB"],
					host: ENV["POSTGRES_HOST"],
					password: ENV["POSTGRES_PASS"],
					user: ENV["POSTGRES_USER"]
				)
			else
				conn = PG.connect(dbname: "forum")
			end

			new_id = conn.exec_params("INSERT INTO topics (topic) VALUES ($1) returning id", [new_topic]).first["id"]

			redirect "/topics/#{new_id}"
		end


		get "/topics/new_topic" do
			#shows the html page where users create new topics
			erb :new_topic
		end


		post "/topics/new_topic" do
			#sends info from form to server
			new_topic = params["new_topic"]
			new_question = params["new_question"]

			if ENV["RACK_ENV"] == 'production'
				conn = PG.connect(
					dbname: ENV["POSTGRES_DB"],
					host: ENV["POSTGRES_HOST"],
					password: ENV["POSTGRES_PASS"],
					user: ENV["POSTGRES_USER"]
				)
			else
				conn = PG.connect(dbname: "forum")
			end

			new_id = conn.exec_params("INSERT INTO topics (topic) VALUES ($1) returning id", [new_topic]).first["id"]
# binding.pry
			redirect "/topics/#{new_id}"

		end


		get "/topics/:topic_id" do
			@@topic_id = params[:topic_id]
			#page listing individual topic with all questions and replies beneath
			@topic = @@db.exec_params("select * from topics where id = $1", [@@topic_id]).first["topic"]
			@questions = @@db.exec_params("select * from questions where topic_id = $1", [@@topic_id.to_i])
			
			@replies = {}
			@questions.each do |question|
				@replies[question["id"]] = @@db.exec_params("select reply from replies where quesiton_id = $1", [question["id"].to_i])
			
			end

			# @questions.each do |question|
			# 	@replies[question["id"]].each do |a_question|
			# 		a_question["reply"] = @@db.exec_params("select reply from replies where quesiton_id = $1", [question["id"].to_i])
			# 	end
			# binding.pry
			# end			

			# binding.pry
			erb :topic_id
		end
		# get "/authors" do
		# 	#list of authors that links to all their original posts
		# 	erb :authors
		# end	


		# get "/topics/:topic_id/new_question" do
		# 	@topic_id = params[:topic_id]
		# 	erb :new_question
		# end


		post "/topics/:topic_id/new_question" do
			new_question = params["new_question"]
			user_id = current_user["id"]
			# @id = @params[:topic_id]
			

			if ENV["RACK_ENV"] == 'production'
				conn = PG.connect(
					dbname: ENV["POSTGRES_DB"],
	        host: ENV["POSTGRES_HOST"],
	        password: ENV["POSTGRES_PASS"],
	        user: ENV["POSTGRES_USER"]
        )
			else
				conn = PG.connect(dbname: "forum")
			end

			@question_id = conn.exec_params("INSERT INTO questions (question, user_id, topic_id) VALUES ($1,$2,$3) returning id",
				[new_question, user_id, @@topic_id]).first["id"]
			# binding.pry
			# do I need more insert commands conn.exec_params("INSERT INTO ")
			
			#erb :go back to the topic page from which the user came
			redirect "/topics/#{@@topic_id}"
		end

		post "/topics/:topic_id/question_id/new_reply" do

			new_reply = params["reply"]
			user_id = current_user["id"]
			question_id = params["question_id"]

			#@@topic_id
			#@@question_id

			@@db.exec_params("insert into replies (reply, user_id, quesiton_id) values ($1, $2, $3)", [new_reply, user_id, question_id.to_i])




			redirect "/topics/#{@@topic_id}"
		end


	end
end