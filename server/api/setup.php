<?php
header("Content-Type: application/json; charset=UTF-8");
require_once "db.php";

try {
    $db->exec("DROP TABLE IF EXISTS items");
    $db->exec("DROP TABLE IF EXISTS users");

    $db->exec("CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'Student',
        matric_no TEXT NOT NULL,
        inasis TEXT NOT NULL,
        phone TEXT NOT NULL,
        is_verified INTEGER DEFAULT 1,
        points INTEGER DEFAULT 0,
        status TEXT DEFAULT 'Active',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )");

    $db->exec("CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reporter_id INTEGER NOT NULL,
        finder_id INTEGER NULL,
        item_name TEXT NOT NULL,
        description TEXT NOT NULL,
        color TEXT NULL,
        date_lost TEXT NOT NULL,
        place TEXT NOT NULL,
        image_path TEXT NULL,
        status TEXT DEFAULT 'Lost',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (reporter_id) REFERENCES users(id)
    )");

    $hashedPassword = password_hash("password123", PASSWORD_DEFAULT);
    $createdAt = date('Y-m-d H:i:s');

    $stmt = $db->prepare("INSERT INTO users (name, email, password, role, matric_no, inasis, phone, is_verified, points, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, 1, 0, ?)");
    
    $stmt->execute(['Ali Bin Ahmad', 'ali_uum@student.uum.edu.my', $hashedPassword, 'Student', '291111', 'Inasis MAS', '012-3456789', $createdAt]);
    $stmt->execute(['Siti Aminah', 'siti_uum@student.uum.edu.my', $hashedPassword, 'Student', '292222', 'Inasis Bank Rakyat', '017-9876543', $createdAt]);
    $stmt->execute(['vaishnavee', 'vaishnaveedoray28@gmail.com', $hashedPassword, 'Student', '309801', 'Inasis MAS', '011-2345678', $createdAt]);

    echo json_encode([
        "status" => "success", 
        "message" => "CONGRATULATIONS! Database fully synchronized with points, verification status, and secure password hashes!"
    ]);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "Setup execution failed: " . $e->getMessage()]);
}
?>