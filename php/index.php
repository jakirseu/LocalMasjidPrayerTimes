<?php
require_once("vendor/autoload.php");
use IslamicNetwork\PrayerTimes\PrayerTimes;

// Load Jamat Data from JSON file
$jsonFile = 'data.json';
$jsonData = file_get_contents($jsonFile);
$jamatData = json_decode($jsonData, true);

// Set default values for Dhaka, Bangladesh (latitude, longitude) if data.json is empty or doesn't have valid values
$latitude = isset($jamatData['latitude']) ? $jamatData['latitude'] : 23.7286277;
$longitude = isset($jamatData['longitude']) ? $jamatData['longitude'] : 90.412831;
$timezone = 'Asia/Dhaka'; // Timezone

// Initialize PrayerTimes
$pt = new PrayerTimes('KARACHI', 'HANAFI');

$date = new DateTime('now', new DateTimeZone($timezone)); // Corrected DateTimeZone
$times = $pt->getTimes($date, $latitude, $longitude , null, PrayerTimes::LATITUDE_ADJUSTMENT_METHOD_ANGLE, null, PrayerTimes::TIME_FORMAT_ISO8601);

// Function to convert ISO8601 to 12-hour format
function convertTo12HourFormat($isoTime) {
    $dateTime = new DateTime($isoTime);
    return $dateTime->format('g:i A'); // 12-hour format with AM/PM
}

// ✅ Select only specific prayers
$selectedPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

// Get Jamat Times from data.json, defaulting to 0 if not set
$jamatTimes = isset($jamatData['jamat']) ? $jamatData['jamat'] : [];

// Check if Jumuah time is set, use the same as Dhuhr if it's not
$jumuahTime = isset($jamatData['jumuah_time']) ? $jamatData['jumuah_time'] : (isset($jamatTimes['Dhuhr']) ? $jamatTimes['Dhuhr'] : 'Not Set');

// Set default values if data.json is empty or doesn't have required fields
$dua_of_the_day = isset($jamatData['dua_of_the_day']) ? $jamatData['dua_of_the_day'] : "اللهم اجعل هذا اليوم يوم خير وبركة";
$hadith_of_the_day = isset($jamatData['hadith_of_the_day']) ? $jamatData['hadith_of_the_day'] : "The best among you are those who have the best manners and character.";
$quran_ayat_of_the_day = isset($jamatData['quran_ayat_of_the_day']) ? $jamatData['quran_ayat_of_the_day'] : "Indeed, Allah is with those who fear Him and those who are doers of good.";

?>

<?php include 'header.php'; ?>

<!-- Header with Mosque Background -->
<div class="header-bg">
    <div class="bg-text">
        <h1>Baitul Mukarram National Mosque</h1>
        <p>Topkhana Road, Paltan Dhaka</p>
    </div>
</div>


<div class="container mt-5">

    <!-- Prayer Times Section -->
    <div class="row">

    <!-- Sehri & Ifter -->
    <div class="col-md-3">
        <div class="card">
            <div class="card-header bg-success text-white">
                <h3>সেহেরি এবং ইফতার</h3>
            </div>
            <div class="card-body">
                <p><strong>সেহেরির শেষ সময়:</strong> 
                    <?php 
                    if (isset($times['Fajr'])) {
                        echo convertTo12HourFormat($times['Fajr']);
                    } else {
                        echo "Not Available";
                    }
                    ?>
                </p>
                <p><strong>ইফতারের সময়:</strong> 
                    <?php 
                    if (isset($times['Sunset'])) {
                        echo convertTo12HourFormat($times['Sunset']);
                    } else {
                        echo "Not Available";
                    }
                    ?>
                </p>
            </div>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card">
            <div class="card-header bg-primary text-white">
                <h3>নামাজ এবং জামাতের সময়</h3>
            </div>
            <div class="card-body">
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>নামাজ</th>
                            <th>আজানের সময়</th>
                            <th>জামাতের সময়</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php
                        foreach ($selectedPrayers as $prayer) {
                            if (isset($times[$prayer])) {
                                // Get the prayer time
                                $prayerTime = convertTo12HourFormat($times[$prayer]);
                                
                                // Get the Jamat time from data.json
                                $jamatTime = isset($jamatTimes[$prayer]) ? $jamatTimes[$prayer] : 'Not Set';
                                
                                // Output the prayer time and Jamat time
                                echo "<tr>
                                        <td><strong>$prayer</strong></td>
                                        <td>$prayerTime</td>
                                        <td>$jamatTime</td>
                                      </tr>";
                            }
                        }

                        // Jumuah time
                        echo "<tr>
                                <td><strong>Jumuah</strong></td>
                                <td>" . convertTo12HourFormat($times['Dhuhr']) . "</td> <!-- Use Dhuhr time for Jumuah -->
                                <td>$jumuahTime</td>
                              </tr>";
                        ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Sunrise and Sunset Section -->
    <div class="col-md-3">
        <div class="card">
            <div class="card-header bg-info text-white">
                <h3>সূর্যদয় এবং সূর্যাস্ত</h3>
            </div>
            <div class="card-body">
                <p><strong>সূর্যদয়:</strong> 
                    <?php 
                    if (isset($times['Sunrise'])) {
                        echo convertTo12HourFormat($times['Sunrise']);
                    } else {
                        echo "Not Available";
                    }
                    ?>
                </p>
                <p><strong>সূর্যাস্ত:</strong> 
                    <?php 
                    if (isset($times['Sunset'])) {
                        echo convertTo12HourFormat($times['Sunset']);
                    } else {
                        echo "Not Available";
                    }
                    ?>
                </p>
            </div>
        </div>
    </div>
</div>


    <!-- Dua, Hadith, and Quran Ayat of the Day Section -->
    <div class="row">
        <div class="col-md-4">
            <div class="card">
                <div class="card-header bg-info text-white">
                    <h3>আজকের দোয়া</h3>
                </div>
                <div class="card-body">
                    <p><?php echo $dua_of_the_day; ?></p>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card">
                <div class="card-header bg-success text-white">
                    <h3>আজকের হাদিস</h3>
                </div>
                <div class="card-body">
                    <p><?php echo $hadith_of_the_day; ?></p>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card">
                <div class="card-header bg-warning text-white">
                    <h3>আজকের আয়াত</h3>
                </div>
                <div class="card-body">
                <p><?= $quran_ayat_of_the_day ?></p>
                </div>
            </div>
        </div>
    </div>

    <div class="container mt-5 py-3">
    <div class="row">
        <!-- Location Details Column -->
        <div class="col-md-12 text-center  ">
            <h4 class="mb-3">Location Details</h4>
            <p class="lead mb-3">
                Latitude: <strong><?= $latitude ?></strong><br>
                Longitude: <strong><?= $longitude ?></strong>
            </p>
            <?php
            $zoom = 20;
            // Create a map URL with the zoom level
            $mapUrl = "https://www.google.com/maps/@$latitude,$longitude,$zoom" . "z";
            ?>
            <a href="<?= $mapUrl ?>" target="_blank" class="btn btn-primary btn-lg">View on Google Maps</a>
        </div>
 
    </div>
</div>



</div>

<?php include 'footer.php'; ?>
