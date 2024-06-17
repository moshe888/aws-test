const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');

const app = express();
app.use(cors());
app.use(express.json());

const db = mysql.createConnection({
    host: 'database-3.crg442gc0lel.eu-central-1.rds.amazonaws.com',  
    user: 'admin',  
    password: '12345678',  
    database: 'scores'  
});

db.connect((err) => {
    if (err) {
        console.error('Error connecting to the database:', err);
        return;
    }
    console.log('Connected to the database');
});

const createScoresTable = `
CREATE TABLE IF NOT EXISTS scores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    score INT NOT NULL,
    mode VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
`;

db.query(createScoresTable, (err, result) => {
    if (err) {
        console.error('Error creating table:', err);
    } else {
        console.log('Table created or already exists');
    }
});

// נקודת קצה POST לשמירת ניקוד חדש
app.post('/api/new-score', (req, res) => {
    const { username, score, mode, timestamp } = req.body;
    console.log('Received data:', { username, score, mode, timestamp });

    if (!username || !score || !mode || !timestamp) {
        return res.status(400).json({ error: 'Invalid data provided' });
    }

    // שאילתא להוספת ניקוד חדש לטבלה
    const query = 'INSERT INTO scores (username, score, mode, timestamp) VALUES (?, ?, ?, ?)';
    db.query(query, [username, score, mode, timestamp], (err, result) => {
        if (err) {
            console.error('Error inserting data:', err);
            return res.status(500).json({ error: 'Error inserting data', details: err.message });
        }
        console.log('Score inserted:', result);
        return res.json({ message: 'Score submitted successfully!' });
    });
});

// נקודת קצה GET לשליפת ניקודים לפי מצב המשחק
app.get('/api/scores', (req, res) => {
    const { mode } = req.query;
    if (!mode) {
        return res.status(400).json({ error: 'Mode is required' });
    }

    // שאילתא לשליפת ניקודים לפי מצב המשחק
    const query = 'SELECT * FROM scores WHERE mode = ?';
    db.query(query, [mode], (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            return res.status(500).json({ error: 'Error fetching data', details: err.message });
        }
        return res.json(results);
    });
});

// התחלת השרת על פורט 3010 או על הפורט שמוגדר במשתנה הסביבה
const port = process.env.PORT || 3010;
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
