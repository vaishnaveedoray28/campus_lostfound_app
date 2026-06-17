<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once "db.php";

// Modified to parse $_POST variables since data arrives as MultiPart Form Data now
$reporter_id = $_POST['reporter_id'] ?? 0;
$item_name   = trim($_POST['item_name'] ?? '');
$description = trim($_POST['description'] ?? '');
$color       = trim($_POST['color'] ?? '');
$date_lost   = trim($_POST['date_lost'] ?? '');
$place       = trim($_POST['place'] ?? '');
$image_path  = ''; 

if (empty($reporter_id) || $reporter_id == 0) {
    $reporter_id = 3; 
}

// Automatically processes incoming binary file blocks from Flutter image_picker
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $fileTmpPath = $_FILES['image']['tmp_name'];
    $fileName    = $_FILES['image']['name'];
    $fileExtension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
    
    // Formulate a clean timestamp name structure (e.g., img_1718625900.jpg)
    $newFileName = 'img_' . time() . '.' . $fileExtension;
    $uploadFileDir = './uploads/';
    
    if (!is_dir($uploadFileDir)) {
        mkdir($uploadFileDir, 0777, true);
    }
    
    $dest_path = $uploadFileDir . $newFileName;
    if (move_uploaded_file($fileTmpPath, $dest_path)) {
        $image_path = "uploads/" . $newFileName; 
    }
}

try {
    $query = "INSERT INTO items (reporter_id, item_name, description, color, date_lost, place, image_path, status) 
              VALUES (?, ?, ?, ?, ?, ?, ?, 'Missing')";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$reporter_id, $item_name, $description, $color, $date_lost, $place, $image_path]);

    echo json_encode([
        "status" => "success", 
        "message" => "Item completely written to database!"
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error", 
        "message" => "Database injection rejected: " . $e->getMessage()
    ]);
}
?>