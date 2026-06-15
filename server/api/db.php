<?php
// C:\xampp\htdocs\lost_found_api\db.php

// Define absolute path constraints to keep file streams secure
$db_file = __DIR__ . '/campus_rewards.db';

try {
    // 1. Establish the PDO connection hook directly into your local SQLite file
    $db = new PDO("sqlite:" . $db_file);
    
    // 2. Set strict error monitoring criteria so SQLite flags query issues instantly
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // 3. Configure row collection mapping format to return clean associative arrays (JSON friendly)
    $db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    
    // 4. Force SQLite to explicitly check and enforce Foreign Key references between users and items
    $db->exec("PRAGMA foreign_keys = ON;");

} catch (PDOException $e) {
    // If the database link fails or falls asleep, output a professional JSON packet back to Flutter
    header('Content-Type: application/json; charset=UTF-8');
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Local SQLite architecture connection pipeline dropped: " . $e->getMessage()
    ]);
    exit();
}
?>