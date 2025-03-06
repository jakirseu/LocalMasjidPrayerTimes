<?php
// Check if form was submitted
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get data from the form
    $map_url = $_POST['map_url'];
    
    // Default coordinates if no map URL is provided
    $latitude = 23.7286277;
    $longitude = 90.412831;
    
    // Check if a map URL is provided and extract latitude and longitude from it
    if (!empty($map_url)) {
        // Regex to extract latitude and longitude from Google Maps URL
        if (preg_match('/@([\-0-9.]+),([\-0-9.]+)/', $map_url, $matches)) {
            $latitude = $matches[1];
            $longitude = $matches[2];
        }
    }

    // Prepare the data to be saved
    $data = [
        'map_url' => $map_url,
        'latitude' => $latitude,
        'longitude' => $longitude,
        'jamat' => [
            'Fajr' => $_POST['fajr'],
            'Dhuhr' => $_POST['dhuhr'],
            'Asr' => $_POST['asr'],
            'Maghrib' => $_POST['maghrib'],
            'Isha' => $_POST['isha'],
            'Jumuah' => $_POST['jumuah']
        ],
        'dua_of_the_day' => $_POST['dua_of_the_day'],
        'hadith_of_the_day' => $_POST['hadith_of_the_day'],
        'quran_ayat_of_the_day' => $_POST['quran_ayat_of_the_day']
    ];

    // Save data to JSON file
    file_put_contents('data.json', json_encode($data, JSON_PRETTY_PRINT));

    // Redirect back to the admin dashboard
    header('Location: admin.php');
    exit();
}
?>
