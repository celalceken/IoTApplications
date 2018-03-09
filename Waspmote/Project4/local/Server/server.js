//gelen x,y,z değerleri için (2000) doğrusal grafik çiziyor.

//gelen x,y,z değerleri için (200) text tabanlı  çiziyor.


//Dependencies

var express = require('express');
var app= express();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var path = require('path');

app.use(express.static(path.join(__dirname,'dist')));

var monk = require("monk"); // a framework that makes accessing MongoDb really easy

/*
var bodyParser = require('body-parser'); //to get the parameters
var morgan     = require('morgan'); // log requests to the console
*/
var should = require("should"); //  It keeps your test code clean, and your error messages helpful.

var SerialPort = require("serialport");

var dateFormat = require('dateformat');

// configurations


/*
app.use(morgan('dev'));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
*/


var serialPort = new SerialPort("/dev/ttyUSB0", {  //"COMx"  for Windows Systems
    baudrate: 115200,
    parser: require("serialport").parsers.readline("\n")
});
//
// var db = monk('localhost/WaspMote');
// should.exists(db);
// var collection = db.get("Acceleration");
// should.exists(collection);


// index.html dosyası istemcilere gönderiliyor...
app.get('/', function(req, res){
    // res.sendFile(__dirname + '/index2.html'); //doğrusal grafik accelerometer icin
    // res.sendFile(__dirname + '/index1.html'); //toggle switch button'u goster PIR sensoru icin
    res.sendFile(__dirname + '/index1.html'); //ruzgar sensoru icin pusula goster

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
        //console.log(dateFormat(date.getTime(), "yyyy-mm-dd HH:MM:ss")+'-->x:'+dataArray[0]+'y:'+dataArray[1]+'z:'+dataArray[2]+'k:'+dataArray[3]+'l:'+dataArray[4]);


        // Tüm istemcilere gönder
        io.emit('alldata', data);

    });


});

