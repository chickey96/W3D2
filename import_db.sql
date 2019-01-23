DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;


PRAGMA foreign_keys = ON;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL   
);

INSERT INTO 
    users (fname, lname)
VALUES
    ('Corinne', 'Hickey'),
    ('JD', 'Salinger'),
    ('Melvin', 'Mallari');


CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    user_id INTEGER,

    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO 
    questions (title, body, user_id)
VALUES
    ('Q1', 'wtf?', (SELECT id FROM users WHERE fname = 'Melvin' AND lname = 'Mallari')),
    ('Q2', 'why?', (SELECT id FROM users WHERE fname = 'JD' AND lname = 'Salinger')),
    ('Q3', '...?', (SELECT id FROM users WHERE fname = 'Corinne' AND lname = 'Hickey'));

CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    question_id INTEGER,
    user_id INTEGER,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO 
    question_follows (question_id, user_id)
VALUES
    ((SELECT id FROM questions WHERE title = 'Q2'),  (SELECT id FROM users WHERE fname = 'Melvin' AND lname = 'Mallari')),
    ((SELECT id FROM questions WHERE title = 'Q3'),  (SELECT id FROM users WHERE fname = 'JD' AND lname = 'Salinger')),
    ((SELECT id FROM questions WHERE title = 'Q3'),  (SELECT id FROM users WHERE fname = 'Corinne' AND lname = 'Hickey'));
CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    question_id INTEGER, 
    parent_id INTEGER,
    user_id INTEGER,
    reply TEXT NOT NULL,
    
    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (parent_id) REFERENCES replies(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
    replies(question_id, parent_id, user_id, reply)
VALUES 
    ((SELECT id FROM questions WHERE title = 'Q1'),  NULL, (SELECT id FROM users WHERE fname = 'JD' AND lname = 'Salinger'), 'So it goes..');

INSERT INTO
    replies(question_id, parent_id, user_id, reply)
VALUES 
    ((SELECT id FROM questions WHERE title = 'Q1'),  (SELECT id FROM replies WHERE reply = 'So it goes..'), (SELECT id FROM users WHERE fname = 'Corinne' AND lname = 'Hickey'), 'That''s what I hear');


CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    question_id INTEGER,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);
INSERT INTO 
    question_likes (user_id, question_id)
VALUES  
    ((SELECT id FROM users WHERE fname = 'Melvin' AND lname = 'Mallari'), (SELECT id FROM questions WHERE title = 'Q1'));

