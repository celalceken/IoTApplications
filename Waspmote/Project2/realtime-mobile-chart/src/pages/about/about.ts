import { Component } from '@angular/core';
import { NavController ,ToastController } from 'ionic-angular';

//Chart
//import { LineChartComponent } from '../../components/line-chart/line-chart'

//Servis
import { socketservice } from '../../app/socket.service';

@Component({
  selector: 'page-about',
  templateUrl: 'about.html'
})

export class AboutPage {

  public temp1=35; public temp0=25;
  public tempHum1=35; public tempHum0=25;
  public temperature =0;
  public humidity = 0;
  message: string;
  public i=2;

  public barChartOptions:any = {
    animation: 
    {
      animateRotate:true
    },
    title: {
      display: true,
      text: 'Sıcaklık ve Nem Durumu'
    },
    scaleShowVerticalLines: false,
    responsive: true
  };
  public barChartLabels:string[] = ['0','0','0'];
  public barChartType:string = 'bar';
  public barChartLegend:boolean = true;

  public barChartData:any[] = [
    {data: [20, 25, 35], label: 'Sıcaklık '},
    {data: [17, 25, 25], label: 'Nem '}
  ];

  constructor(public navCtrl: NavController,
      private toastCtrl: ToastController,
      private ss:socketservice) {
      ss.getMessage().subscribe((msg: any[]) => {
      // const myObjStr = JSON.stringify(msg);
      //console.log(JSON.parse(myObjStr));
      //Grafik ayarları
      this.ngChartConfig();
      //Grafikde zamanın alındığı bölüm
      this.ngSetTime();
      //Değerlerin atıldığı bölüm
      this.temperature = parseInt(this.ss.getData(msg,"temp"));
      this.humidity = parseInt(this.ss.getData(msg,"hum"));

      let data = [this.temp0,this.temp1,this.temperature,];
      let dataHum = [this.tempHum0,this.tempHum1, this.humidity];
      let clone = JSON.parse(JSON.stringify(this.barChartData));
      clone[0].data = data; clone[1].data = dataHum;
      this.barChartData = clone;
      this.tempHum0 =this.tempHum1; this.temp0 = this.temp1;
      this.tempHum1 = this.humidity; this.temp1 = this.temperature;
  })
}
 public ngChartConfig(){
    //Bir fonksiyon içine sonra alınmalı
    this.barChartOptions= {
      animation:false,
      title: {
        display: true,
        text: 'RTC İç Sıcalık Bilgisi'
      },
      scaleShowVerticalLines: true,
      responsive: true
    };
 }

 public ngSetTime(){
    var x ;
    var dayTwo = new Date();
    var hrNow = dayTwo.getHours();
    var mnNow = dayTwo.getMinutes(); 
    var scNow = dayTwo.getSeconds();
    x = hrNow + ":" + mnNow + ":" + scNow;
    let _barChartLabels=['','',''];
    for(let j= 2; 0<=j ; j--)
    {
        _barChartLabels[j-1]=this.barChartLabels[j];
        if(j == 2){
          _barChartLabels[j]=x +'';
        }
    }
    //Sebebini bilmediğim bir nedenden dolayı this.barChartLabels=_barChartLabels; bu eşitleme 
     //grafiğin anlık olarak değişmesini engellemekte
     for(let i=0; i<=2 ; i++)
     {
      this.barChartLabels[i]=_barChartLabels[i];
     }
 }
  // events
  public chartClicked(e:any):void {
    console.log(e);
  }

  public chartHovered(e:any):void {
    console.log(e);
  }
/*
  public randomize():void {
    console.log('randomize');
    // Only Change 3 values
    let data = [
      Math.round(Math.random() * 100),
      59,
      80,
      (Math.random() * 100),
      56,
      (Math.random() * 100),
      40];
    let clone = JSON.parse(JSON.stringify(this.barChartData));
    clone[0].data = data;
    this.barChartData = clone;
  }
    /**
     * (My guess), for Angular to recognize the change in the dataset
     * it has to change the dataset variable directly,
     * so one way around it, is to clone the data, change it and then
     * assign it;
     */

    showToast(msg) {
      let toast = this.toastCtrl.create({
        message: msg,
        duration: 2000
      });
      toast.present();
    }
}
