# With Pagination (Generic Format)
import requests
import mysql.connector

# TMDb API Key
# To get your API key, register here first: https://www.themoviedb.org/
# Then, go to link: https://developer.themoviedb.org/docs/getting-started
API_KEY = "your_api_key_here"
BASE_URL = "https://api.themoviedb.org/3"

# MySQL Connection
conn = mysql.connector.connect(
    host="your_host",
    user="your_user",
    password="your_password",
    database="your_database"
)
cursor = conn.cursor()
# Fetch Genres
def fetch_genres():
    try:
        url = f"{BASE_URL}/genre/movie/list?api_key={API_KEY}"
        response = requests.get(url)
        if response.status_code == 200:
            genres = response.json().get("genres", [])
            for genre in genres:
                cursor.execute(
                "INSERT INTO genres (genre_id, genre_name) VALUES (%s, %s) ON DUPLICATE KEY UPDATE genre_name=%s",
                (genre["id"], genre["name"], genre["name"])
                )
            conn.commit()
            print("Genres inserted!")
        else:
            print(f"Error fetching page, Status Code: {response.status_code}")
    except:
        print(f"Exception Error fetching page, StatusCode: {response.status_code}")

# Fetch Popular Movies
def fetch_movies():             
    try:
        movies = []
        total_pages = 10
        for page in range(1, total_pages + 1):
            url = f"{BASE_URL}/movie/popular?api_key={API_KEY}&page={page}"
            response = requests.get(url)
            if response.status_code == 200:
                data = response.json()
                movies.extend(data['results'])  # Append results from each page
                for movie in movies:
                    cursor.execute(
                    "INSERT INTO movies(movie_id, title, release_date, genre_id, rating, vote_count) VALUES (%s, %s, %s, %s, %s, %s) ON DUPLICATE KEY UPDATE title=%s",
                    (movie["id"], movie["title"], movie["release_date"] if movie["release_date"] else None, movie["genre_ids"][0] if movie["genre_ids"] else None, movie["vote_average"], movie["vote_count"], movie["title"])
                    )
                conn.commit()
                print(f"Page {page}: Movies data inserted!")
            elif response.status_code == 400:
                print(f"Invalid page number, Status Code: {response.status_code}")
            else:
                print(f"Error fetching page, Status Code: {response.status_code}")
    except:
        print(f"Exception Error fetching page, StatusCode: {response.status_code}")
    
fetch_genres()
fetch_movies()
# Close connection
cursor.close()
conn.close()
