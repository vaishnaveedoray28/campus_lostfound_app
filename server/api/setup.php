<?php
// C:\xampp\htdocs\lost_found_api\setup.php
header("Content-Type: application/json; charset=UTF-8");
require_once "db.php";

try {
    // Drop existing tables to establish the perfect schema structure
    $db->exec("DROP TABLE IF EXISTS items");
    $db->exec("DROP TABLE IF EXISTS users");

    // 1. Create Users Table - Removed role and is_verified columns
    $db->exec("CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        matric_no TEXT NOT NULL,
        inasis TEXT NOT NULL,
        phone TEXT NOT NULL,
        points INTEGER DEFAULT 0,
        status TEXT DEFAULT 'Active',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )");

    // 2. Create Items Table - Removed image_path column and set default status to 'Missing'
    $db->exec("CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reporter_id INTEGER NOT NULL,
        finder_id INTEGER NULL,
        finder_phone TEXT NULL,
        item_name TEXT NOT NULL,
        description TEXT NOT NULL,
        color TEXT NULL,
        date_lost TEXT NOT NULL,
        place TEXT NOT NULL,
        status TEXT DEFAULT 'Missing',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (reporter_id) REFERENCES users(id),
        FOREIGN KEY (finder_id) REFERENCES users(id)
    )");

    // Securely hash passwords so password_verify() in your login.php works perfectly!
    $hashedPassword = password_hash("password123", PASSWORD_DEFAULT);
    $createdAt = date('Y-m-d H:i:s');

    // 3. Insert testing seed accounts matching the simplified schema
    $stmt = $db->prepare("INSERT INTO users (name, email, password, matric_no, inasis, phone, points, created_at) VALUES (?, ?, ?, ?, ?, ?, 0, ?)");
    
    $stmt->execute(['Ali Bin Ahmad', 'ali_uum@student.uum.edu.my', $hashedPassword, '291111', 'Inasis MAS', '012-3456789', $createdAt]);
    $stmt->execute(['Siti Aminah', 'siti_uum@student.uum.edu.my', $hashedPassword, '292222', 'Inasis Bank Rakyat', '017-9876543', $createdAt]);
    $stmt->execute(['vaishnavee', 'vaishnaveedoray28@gmail.com', $hashedPassword, '309801', 'Inasis MAS', '011-2345678', $createdAt]);

    echo json_encode([
        "status" => "success", 
        "message" => "CONGRATULATIONS! Database fully synchronized with points and secure password hashes!"
    ]);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "Setup execution failed: " . $e->getMessage()]);
}
?>