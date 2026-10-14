
import sqlite3

DB_NAME = "wardrobe.db"


def create_database():
    connection = sqlite3.connect(DB_NAME)

    cursor = connection.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS clothes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            image BLOB
        )
    """)
    
    try:
        cursor.execute(
            "ALTER TABLE clothes ADD COLUMN is_favorite INTEGER DEFAULT 0"
        )
    except sqlite3.OperationalError:
        pass

    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS outfits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            occasion TEXT NOT NULL,
            items TEXT NOT NULL
        )
    """)

    connection.commit()
    connection.close()


def add_clothing(name, category, image):
    connection = sqlite3.connect(DB_NAME)

    cursor = connection.cursor()

    cursor.execute("""
        INSERT INTO clothes (name, category, image)
        VALUES (?, ?, ?)
    """, (name, category, image))

    connection.commit()
    connection.close()


def get_clothes():
    connection = sqlite3.connect(DB_NAME)
    connection.row_factory = sqlite3.Row

    cursor = connection.cursor()
    cursor.execute("SELECT * FROM clothes ORDER BY id DESC")

    clothes = [dict(row) for row in cursor.fetchall()]

    connection.close()
    return clothes


def delete_clothing(item_id):
    connection = sqlite3.connect(DB_NAME)

    cursor = connection.cursor()
    cursor.execute(
        "DELETE FROM clothes WHERE id = ?",
        (item_id,)
    )

    connection.commit()
    connection.close()


if __name__ == "__main__":
    create_database()
    print("Database is ready!")


def update_clothing(item_id, name, category):
    connection = sqlite3.connect(DB_NAME)
    cursor = connection.cursor()

    cursor.execute("""
        UPDATE clothes
        SET name = ?, category = ?
        WHERE id = ?
    """, (name, category, item_id))

    connection.commit()
    connection.close()

def toggle_favorite(item_id, is_favorite):
    connection = sqlite3.connect(DB_NAME)
    cursor = connection.cursor()

    cursor.execute(
        "UPDATE clothes SET is_favorite = ? WHERE id = ?",
        (is_favorite, item_id)
    )

    connection.commit()
    connection.close()


def get_favorites():
    connection = sqlite3.connect(DB_NAME)
    connection.row_factory = sqlite3.Row
    cursor = connection.cursor()

    cursor.execute(
        "SELECT * FROM clothes WHERE is_favorite = 1 ORDER BY id DESC"
    )

    favorites = [dict(row) for row in cursor.fetchall()]

    connection.close()
    return favorites


def toggle_favorite(item_id, is_favorite):
    connection = sqlite3.connect(DB_NAME)
    cursor = connection.cursor()

    cursor.execute(
        "UPDATE clothes SET is_favorite = ? WHERE id = ?",
        (is_favorite, item_id)
    )

    connection.commit()
    connection.close()


def get_favorites():
    connection = sqlite3.connect(DB_NAME)
    connection.row_factory = sqlite3.Row
    cursor = connection.cursor()

    cursor.execute(
        "SELECT * FROM clothes WHERE is_favorite = 1 ORDER BY id DESC"
    )

    favorites = [dict(row) for row in cursor.fetchall()]

    connection.close()
    return favorites



def save_outfit(outfit_name, occasion, items):
    import json

    connection = sqlite3.connect(DB_NAME)
    cursor = connection.cursor()

    # Check the columns in the existing outfits table
    cursor.execute(
        "PRAGMA table_info(outfits)"
    )
    columns = [
        row[1] for row in cursor.fetchall()
    ]

    # Create the table if it does not exist
    if not columns:
        cursor.execute("""
            CREATE TABLE outfits (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                occasion TEXT NOT NULL,
                items TEXT NOT NULL
            )
        """)
        columns = ["id", "name", "occasion", "items"]

    # Use the name column supported by the existing table
    name_column = (
        "outfit_name"
        if "outfit_name" in columns
        else "name"
    )

    items_json = json.dumps(items)

    cursor.execute(
        f'INSERT INTO outfits ("{name_column}", occasion, items) VALUES (?, ?, ?)',
        (outfit_name, occasion, items_json)
    )

    connection.commit()
    connection.close()


def get_outfits():
    import json

    connection = sqlite3.connect(DB_NAME)
    connection.row_factory = sqlite3.Row
    cursor = connection.cursor()

    cursor.execute("SELECT * FROM outfits ORDER BY id DESC")
    outfits = []

    for row in cursor.fetchall():
        outfit = dict(row)
        outfit["items"] = json.loads(outfit["items"])
        outfits.append(outfit)

    connection.close()
    return outfits


def delete_outfit(outfit_id):
    connection = sqlite3.connect(DB_NAME)
    cursor = connection.cursor()

    cursor.execute(
        "DELETE FROM outfits WHERE id = ?",
        (outfit_id,)
    )

    connection.commit()
    connection.close()

