DROP TABLE IF EXISTS topics CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS questions CASCADE;
DROP TABLE IF EXISTS replies CASCADE;

CREATE TABLE topics (
	id serial primary key,
	topic varchar not null
);

CREATE TABLE users (
	id serial primary key,
	user_name varchar not null,
	password_digest varchar not null,
	num_of_topics_created integer not null
);

CREATE TABLE questions (
	id serial primary key,
	question varchar not null,
	user_id integer references users(id),
	topic_id integer references topics(id)
);

CREATE TABLE replies (
	id serial primary key,
	reply varchar not null,
	user_id integer references users(id),
	quesiton_id integer references questions(id)
);

-- CREATE TABLE topics_users (
-- 	id serial not null,
-- 	topic_id integer references topics(id),
-- 	user_id integer references users(id)
-- )



