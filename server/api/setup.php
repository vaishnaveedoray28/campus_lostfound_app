<?php
// setup.php
header("Content-Type: application/json; charset=UTF-8");
date_default_timezone_set('Asia/Kuala_Lumpur');

require_once __DIR__ . '/db.php';

try {
    $db->exec("DROP TABLE IF EXISTS items;");
    $db->exec("DROP TABLE IF EXISTS users;");

    // Added matric_no and inasis columns
    $createUsersTable = "
        CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            matric_no TEXT UNIQUE NOT NULL,
            inasis TEXT NOT NULL,
            phone TEXT NOT NULL,
            password TEXT NOT NULL,
            role TEXT NOT NULL,
            profile_image TEXT DEFAULT '',
            created_at TEXT NOT NULL,
            is_verified INTEGER DEFAULT 1,
            points INTEGER DEFAULT 0
        );
    ";
    $db->exec($createUsersTable);

    // Added color and image_path columns
    $createItemsTable = "
        CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            reporter_id INTEGER NOT NULL,
            finder_id INTEGER DEFAULT NULL,
            item_name TEXT NOT NULL,
            description TEXT NOT NULL,
            color TEXT,
            image_path TEXT DEFAULT NULL,
            date_lost TEXT NOT NULL,
            place TEXT NOT NULL,
            status TEXT DEFAULT 'Lost',
            collection_note TEXT DEFAULT NULL,
            FOREIGN KEY (reporter_id) REFERENCES users(id),
            FOREIGN KEY (finder_id) REFERENCES users(id)
        );
    ";
    $db->exec($createItemsTable);

    $hashedPassword = password_hash("password123", PASSWORD_DEFAULT);
    $timestamp = date('Y-m-d H:i:s');

    // Preseed sample users with matric numbers and inasis locations
    $insertUser = $db->prepare("
        INSERT INTO users (name, email, matric_no, inasis, phone, password, role, created_at, is_verified, points) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?)
    ");
    
    $insertUser->execute(["Ali Bin Ahmad", "ali_uum@student.uum.edu.my", "291111", "Inasis MAS", "0123456789", $hashedPassword, "Student", $timestamp, 150]);
    $insertUser->execute(["Siti Aminah", "siti_uum@student.uum.edu.my", "292222", "Inasis Bank Rakyat", "0198765432", $hashedPassword, "Student", $timestamp, 20]);

    echo json_encode([
        "status" => "success",
        "message" => "Database tables updated! Re-seeded Ali and Siti with Matric Numbers and Inasis details."
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Database initialization failed: " . $e->getMessage()]);
}
?>