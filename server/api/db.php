<?php

$db_file = __DIR__ . '/campus_rewards.db';

try {

    $db = new PDO("sqlite:" . $db_file);
    
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    
    $db->exec("PRAGMA foreign_keys = ON;");

} catch (PDOException $e) {
    header('Content-Type: application/json; charset=UTF-8');
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Local SQLite architecture connection pipeline dropped: " . $e->getMessage()
    ]);
    exit();
}
?>