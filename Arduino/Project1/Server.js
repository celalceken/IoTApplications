/*
* Arduino PIR and Temperature Sensors
*
* */


//Dependencies

var express = require('express');
var app= express();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var StringDecoder = require('string_decoder').StringDecoder;
var path = require('path');
var decoder = new StringDecoder('utf8');
var monk = require("monk"); // MongoDb driver
var should = require("should"); //  for more clear error messages
var serialport = require("serialport");
var dateFormat = require('dateformat');

// configurations
var Readline = serialport.parsers.Readline;


//var serialPort = new serialport("/dev/ttyUSB0", { //Linux
//var serialPort = new serialport("COM3", {         //Win

var serialPort = new serialport("/dev/tty.usbserial-1410", {
    baudRate: 115200,
    parser:  new Readline('\n')
});

var db = monk('localhost/Arduino');
should.exists(db);
var collection = db.get("PIRandTemperature");
should.exists(collection);

app.use('/node_modules', express.static(path.join(__dirname, 'node_modules')))
app.use('/js', express.static(path.join(__dirname, 'js')))

//app.use(express.static('js'));

// index.html dosyası istemcilere gönderiliyor...
app.get('/', function(req, res){
    res.sendFile(__dirname + '/index.html');
});


// Start server

var port=8080;
http.listen(port, function(){
    console.log('Listening ' + port);
});



//Web Socket

io.on('connection', function(socket) {
    console.log('Connected');

    socket.on('disconnect', function () {
        console.log('Disconnected');
    });
});


//Serial Port Operations

serialPort.on("open", function ()
{
    // Read from USB
    serialPort.on('data', function(data) {
        console.log(data);
        console.log(decoder.write(data));
        //var daten=[];
        //daten=data.toString('utf8');
        //console.log(daten);

        // Emit the data from serial port to all connected clients
        io.emit('alldata', decoder.write(data));
        data=data+'';
        var date = new Date();

        var dataArray = data.split(':');
        //console.log(dateFormat(date.getTime(), "yyyy-mm-dd HH:MM:ss")+'-->x:'+dataArray[0]+'y:'+dataArray[1]+'z:'+dataArray[2]+'k:'+dataArray[3]+'l:'+dataArray[4]);

        // MongoDB ye kaydet...
        collection.insert({
            "time": dateFormat(date.getTime(), "yyyy-mm-dd HH:MM:ss"),
            "x": dataArray[0],
            "y": dataArray[1],

        }, function (err, doc) {
            if (err) {
                console.log("HATA");
            }
        });

    });
});
