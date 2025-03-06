<?php
require_once("../vendor/autoload.php");
use IslamicNetwork\PrayerTimes\PrayerTimes;

// Define your location details
$latitude = 23.8103;  // Example: Dhaka, Bangladesh
$longitude = 90.4125;
$timezone = 'Asia/Dhaka'; // Timezone

$pt = new PrayerTimes('KARACHI');
$date = new DateTime('2025-03-05', new DateTimezone('Asia/Dhaka'));
$times = $pt->getTimes($date, $latitude, $longitude , null, PrayerTimes::LATITUDE_ADJUSTMENT_METHOD_ANGLE, null, PrayerTimes::TIME_FORMAT_ISO8601);

// Function to convert ISO8601 to 12-hour format
function convertTo12HourFormat($isoTime) {
    $dateTime = new DateTime($isoTime);
    return $dateTime->format('g:i A'); // 12-hour format with AM/PM
}

// Display the results
echo "<h2>Prayer Times</h2>";
echo "<ul>";
foreach ($times as $prayer => $time) {
    echo "<li><strong>$prayer:</strong> " . convertTo12HourFormat($time) . "</li>";
}
echo "</ul>";

?>
