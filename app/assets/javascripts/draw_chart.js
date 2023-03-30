google.charts.load('current', {'packages': ['corechart']});
google.charts.setOnLoadCallback(drawChart);

function drawChart() {
    var xhr = new XMLHttpRequest();
    xhr.responseType = 'json';
    xhr.open('GET', setApiUrl());
    xhr.send();
    xhr.onload = function() {
        drawChartOnLoad(xhr);
    };
}
