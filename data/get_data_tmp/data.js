function init() {

    function formatDate(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();

        if (month.length < 2)
            month = '0' + month;
        if (day.length < 2)
            day = '0' + day;

        return [year, month, day].join('-');
    }

    function addDays(date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    }

    function parse(data) {
        var cache = {};
        var levels = [[], [0], [1], [0, 1], [2], [0, 2], [1, 2], [0, 1, 2]]; // expanded binary matrix
        var result = [];

        data.forEach(function (d) {

            // static fields
            var r = {
                id: d[0],
                //parent: d[1] || null,
                label: d[2] || null,
                label_parent: d[3] || null,
                lon: d[4] || NaN,
                lat: d[5] || NaN,
                population: +d[6] || NaN,
            };

            // restore time series
            var collect = [0, 0, 0];
            d[13].forEach(function (l, i, a) {

                // delta to absolute
                collect[0] += d[10][i];
                collect[1] += d[11][i];
                collect[2] += d[12][i];
                var myDate = new Date(((d[9] * 86400000 + i) + 1577833200000));

                // assemble 
                result.push({
                    ...r,
                    //levels: levels[l],
                    date: formatDate(addDays(myDate, i)),
                    confirmed: collect[0],
                    recovered: collect[1],
                    deaths: collect[2]
                });
            });
        });

        return result;
    };

    function download_file(name, contents, mime_type) {
        mime_type = mime_type || "text/plain";

        var blob = new Blob([contents], {
            type: mime_type
        });

        var dlink = document.createElement('a');
        dlink.download = name;
        dlink.href = window.URL.createObjectURL(blob);
        dlink.onclick = function (e) {
            // revokeObjectURL needs a delay to work properly
            var that = this;
            setTimeout(function () {
                window.URL.revokeObjectURL(that.href);
            }, 1500);
        };

        dlink.click();
        dlink.remove();
    }

    var request = $.ajax({
        url: "https://interaktiv.morgenpost.de/data/corona/history.compact.json"
    });

    request.done(function (msg) {
        download_file("covid-data.json", JSON.stringify(parse(msg)), "text/json");
    });

    request.fail(function (jqXHR, textStatus) {
        alert("Request failed: " + textStatus);
    });


}
