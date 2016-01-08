showDisclaimer = function() {
    bootbox.alert('Please make sure you have read the <a href="/policy/data">Data Privacy</a> guidelines before downloading. If secure data has been downloaded to your computer, it is your job to keep it secure. Click OK to download.', function() {
        window.location = '/raw/protected/residents.csv';
    });
}