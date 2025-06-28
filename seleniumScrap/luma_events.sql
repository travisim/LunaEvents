CREATE TABLE luma_events (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    date VARCHAR(50),
    time VARCHAR(50),
    location VARCHAR(255),
    organizer VARCHAR(255),
    status VARCHAR(100),
    cover_image TEXT,
    link TEXT
);
