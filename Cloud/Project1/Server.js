

var sourceFile = require('./info');
var mqtt = require('mqtt');
var topicName = mqttParameters.topic;



//console.log(login.username);

var client = mqtt.connect(mqttParameters.brokerURL,{
    port: 8883,
    username: mqttParameters.username,
    password: mqttParameters.password
});

client.on('connect', () => {
    client.subscribe(mqttParameters.topic);
});

client.on('connect', function(){
    //setInterval(function(){client.publish(my_topic_name,'1');},3000);
    setInterval(function(){client.publish(mqttParameters.topic,Math.floor(Math.random() * Math.floor(50)).toString())},10000);

});

client.on('error', (error) => {
    console.log('MQTT Client Errored');
console.log(error);
});

client.on('message', function (topic, message) {
    console.log(message.toString()); // for demo purposes.
});
