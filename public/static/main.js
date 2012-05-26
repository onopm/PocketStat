
var socket = io.connect();

socket.on('data', function(d) {
    $("#server_time").empty();
    $("#server_time").append(d.time);

    var nav_cpu_data = [];
    for(var i=0;i<d.vmstat_flot.length;i++){
        if(d.vmstat_flot[i].label != 'idle'){
            nav_cpu_data[i] = d.vmstat_flot[i];
        }
    }
    var nav_cpu_options = {
        series: {
            stack: true,
            bars: {show: true}
        },
        legend: { show: false },
        xaxis:  { show: false },
        yaxis:  { show: false, max: 100 }
    };
    var nav_cpu = $.plot($('#nav_cpu'), nav_cpu_data, nav_cpu_options);

    var nav_clock = $.plot($('#nav_clock'), d.data_pie, {
        series: {
            pie: {
                show: true, 
                radius: 1, 
                stroke: {
                    color: '#666',
                    width: 1
                },
                label: { show: false }
            }
        },
        legend: { show: false }
    });

    //----------------------------------------------------------

    var cpu_flot = $.plot($('#cpu_flot'), d.vmstat_flot, {
        legend: { position: "nw" },
        yaxis:  { max: 100 }
    });

    var cpu_pie = $.plot($('#cpu_pie'), d.vmstat_pie, {
        series: {
            pie: {
                show: true,
                radius: 1,
                label: {
                    show: true,
                    radius: 1,
                    formatter: function(label,series){
                        return '<div style="font-size:8pt;text-align:center;padding:2px;color:white;">'+label+'<br/>'+Math.round(series.percent)+'</div>';
                    },
                    background: {opacity: 0.5, color: "#000" }
                }
            }
        },
        legend: {
            show: false
        }
    });

});
