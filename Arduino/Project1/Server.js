
//gelen x,y,z değerleri için (200) text tabanlı  çiziyor.


//Dependencies

var express = require('express');
var app= express();
var http = require('http').Server(app);
var io = require('socket.io')(http);

app.use(express.static('JS'));

var monk = require("monk"); // a framework that makes accessing MongoDb really easy

/*
 var bodyParser = require('body-parser'); //to get the parameters
 var morgan     = require('morgan'); // log requests to the console
 */
var should = require("should"); //  It keeps your test code clean, and your error messages helpful.

var SerialPort = require("serialport").SerialPort;

var dateFormat = require('dateformat');

// configurations


var serialPort = new SerialPort("/dev/ttyUSB0", {
    baudrate: 115200,
    parser: require("serialport").parsers.readline("\n")
});

var db = monk('localhost/WaspMote');
should.exists(db);
var collection = db.get("Acceleration");
should.exists(collection);


// index.html dosyası istemcilere gönderiliyor...
app.get('/', function(req, res){
    res.sendFile(__dirname + '/index.html'); //metin tabanlı grafik
});


// Start server

var port=8080;
http.listen(port, function(){
    console.log('Listening ' + port);
});



//Web Socket

io.on('connection', function(socket)
{
    console.log('Bir kullanıcı bağlandı');

    socket.on('disconnect', function()
    {
        console.log('Kullanıcı ayrıldı...');
    });
});


//Serial Port Operations

serialPort.on("open", function ()
{
    // Seri porttan okuma
    serialPort.on('data', function(data)
    {
        console.log(data);
        var date = new Date();
        var dataArray = data.split(':');
        //console.log(dateFormat(date.getTime(), "yyyy-mm-dd HH:MM:ss")+'-->x:'+dataArray[0]+'y:'+dataArray[1]+'z:'+dataArray[2]+'k:'+dataArray[3]+'l:'+dataArray[4]);

        console.log('\n');

        var temp= dateFormat(date.getTime(), "yyyy-mm-dd HH:MM:ss")+'-->x:'+dataArray[0]+'y:'+dataArray[1]+'z:'+dataArray[2];

        var x=dataArray[0];
        // Tüm istemcilere gönder
        io.emit('alldata', data);

        // MongoDB ye kaydet...
        collection.insert({"time":dateFormat(date.getTime(), "yyyy-mm-dd HH:MM:ss"), "x": dataArray[0],"y": dataArray[1],"z": dataArray[2] }, function(err, doc)
        {
            if(err)
            {
                console.log("HATA");
            }
            /*else
             {
             console.log("eklendi - ");
             }*/
        });
    });


});

