Create database moviesDB;
use moviesDB;

-- Popular movies
CREATE TABLE moviesDB.movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    release_date DATE,
    genre_id INT,
    rating DECIMAL,
    vote_count INT
);

-- Movie Genres
CREATE TABLE moviesDB.genres (
    genre_id INT PRIMARY KEY,
    genre_name VARCHAR(100) NOT NULL
);

-- 1. Top 10 highest-rated movies by genre
select temp.title, g.genre_name, temp.vote_count, temp.rating
from moviesDB.genres g
join
    (with t1 as (
select m.genre_id, m.title, m.vote_count,
       dense_rank() over (partition by m.genre_id order by m.rating desc, m.vote_count desc) rating
from moviesDB.movies m
where m.genre_id is not null)
select t1.genre_id, t1.title, t1.vote_count, t1.rating
from t1
where t1.rating = 1)temp
on g.genre_id = temp.genre_id
order by temp.vote_count desc
limit 10
;