const db = require('../config/database');
const { v4: uuidv4 } = require('uuid');

class EventService {
    async findAll() {
        const [rows] = await db.query(
            'SELECT * FROM events ORDER BY eventDate ASC'
        );
        return rows;
    }

    async findById(id) {
        const [rows] = await db.query('SELECT * FROM events WHERE id = ?', [id]);
        return rows[0];
    }

    async create(data) {
        const id = uuidv4();
        const { title, description, eventDate, location, imageUrl, isActive = true } = data;

        await db.query(
            `INSERT INTO events (id, title, description, eventDate, location, imageUrl, isActive)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [id, title, description, eventDate, location, imageUrl, isActive]
        );

        return this.findById(id);
    }

    async update(id, data) {
        const { title, description, eventDate, location, imageUrl, isActive } = data;

        await db.query(
            `UPDATE events SET 
        title = COALESCE(?, title),
        description = COALESCE(?, description),
        eventDate = COALESCE(?, eventDate),
        location = COALESCE(?, location),
        imageUrl = COALESCE(?, imageUrl),
        isActive = COALESCE(?, isActive),
        updatedAt = NOW()
      WHERE id = ?`,
            [title, description, eventDate, location, imageUrl, isActive, id]
        );

        return this.findById(id);
    }

    async delete(id) {
        await db.query('DELETE FROM events WHERE id = ?', [id]);
        return { deleted: true };
    }
}

module.exports = new EventService();
