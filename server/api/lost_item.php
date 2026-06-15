<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require_once "db.php";

$data = json_decode(file_get_contents("php://input"), true);

$reporter_id = $data['reporter_id'] ?? '';
$item_name   = trim($data['item_name'] ?? '');
$description = trim($data['description'] ?? '');
$color       = trim($data['color'] ?? '');
$date_lost   = trim($data['date_lost'] ?? '');
$place       = trim($data['place'] ?? '');
$image_path  = trim($data['image_path'] ?? ''); 

if (empty($reporter_id) || empty($item_name) || empty($description) || empty($date_lost) || empty($place)) {
    echo json_encode(["status" => "error", "message" => "Name, Time, Description, and Place are strictly required field parameters."]);
    exit;
}

try {
    $stmt = $db->prepare("INSERT INTO items (reporter_id, item_name, description, color, date_lost, place, image_path, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'Lost')");
    $stmt->execute([$reporter_id, $item_name, $description, $color, $date_lost, $place, $image_path]);

    echo json_encode(["status" => "success", "message" => "Your lost item report has been pinned to the campus feed!"]);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>