import { Component } from '@angular/core';
import { NavController} from 'ionic-angular';

//Servis
import { socketservice } from '../../app/socket.service';
import { ToastController } from 'ionic-angular/components/toast/toast-controller';


@Component({
  selector: 'page-home',
  templateUrl: 'home.html'
})
export class HomePage {
  public dataArray;
  //platformList: string = '';
  showToast(msg) {
    let toast = this.toastCtrl.create({
      message: msg,
      duration: 2000
    });
    toast.present();
  }

  public barChartOptions:any = {
    animation: 
    {
      animateRotate:true
    },
    title: {
      display: true,
      text: 'Anlık Konum Bilgisi'
    },
    scaleShowVerticalLines: false,
    responsive: true
  };
  public barChartLabels:string[] = ['0'];
  public barChartType:string = 'bar';
  public barChartLegend:boolean = true;

  public barChartData:any[] = [
    {data: [0], label: ' X '},
    {data: [0], label: ' Y '},
    {data: [0], label: ' Z '}
  ];

  constructor(public navCtrl: NavController,
              private ss:socketservice,
              private toastCtrl: ToastController) {
              
                //Sayfanın biçimine karar veriyoruz.
                ss.route();            
                ss.getMessage().subscribe((msg: any[]) => {
                  const myObjStr = JSON.stringify(msg);
                  console.log(JSON.parse(myObjStr));
                  this.dataArray = this.ss.getData(msg,"ACC").split(';');
                  //Grafiğin datalarını güncelleme
                  this.setChart();
                  //Grafiğin zamanını güncelleme  
                  this.ngLineSetTime();

                  this.ngBarChartConfig();
                  this.ngSetTime();
                  let clone = JSON.parse(JSON.stringify(this.barChartData));
                  clone[0].data[0] = this.dataArray[0];
                  clone[1].data[0] = this.dataArray[1];
                  clone[2].data[0] = this.dataArray[2];
                  this.barChartData = clone;
                  

                })
              
  }
  public ngSetTime(){
    var x ;
    var dayTwo = new Date();
    var hrNow = dayTwo.getHours();
    var mnNow = dayTwo.getMinutes(); 
    var scNow = dayTwo.getSeconds();
    x = hrNow + ":" + mnNow + ":" + scNow;
    let _barChartLabels=['']; _barChartLabels[0]=x +'';
     
      this.barChartLabels[0]=_barChartLabels[0];
     
 }

  public ngBarChartConfig(){
    //Bir fonksiyon içine sonra alınmalı
    this.barChartOptions= {
      animation:false,
      title: {
        display: true,
        text: 'Anlık Konum Bilgisi'
      },
      scaleShowVerticalLines: true,
      responsive: true
    };
 }

  public setChart():void {
    
    let _lineChartData:Array<any> = new Array(3);
    // XYZ olmak üzere 3 alanımız var alternatif olarak this.lineChartData.length kullanılabilir
    for (let i = 0; i < 3; i++)
    {
        // Grafiğim güzel gözükmesi açısından sadece her data alanın yedi adet datası var alternatif this.lineChartData[i].data.length
        _lineChartData[i] = {data: new Array(7), label: this.lineChartData[i].label};
          //0,1......,6 ----> 7 adet 
          for (let j = 6; 0 <= j; j--)
          {
                //öteleme işlemi
            _lineChartData[i].data[j-1] = this.lineChartData[i].data[j];
            //sonuncu elemanı yerleştir
            if( j == 6 ){
              _lineChartData[i].data[j] = this.dataArray[i];
            } 
          }
      }
      //Son olarak grafiği güncelleme
        this.lineChartData = _lineChartData;
  }
  /**
   *  Zaman bilgisi bu chartsa özel olduğundan ayrı bir fonksiyon yazma ihtiyacı duydum.
   */
  public ngLineSetTime():void {
     var x ; var dayTwo = new Date();var hrNow = dayTwo.getHours();
     var mnNow = dayTwo.getMinutes(); var scNow = dayTwo.getSeconds();
     x = hrNow + ":" + mnNow + ":" + scNow;
     let _lineChartLabels=[];
     for(let i = 6; 0 <= i; i--){
      if(i==0) break;
      //öteleme
      _lineChartLabels[i-1]=this.lineChartLabels[i];
      if(i==6){
        _lineChartLabels[i]= x; 
        }
     }
     //Sebebini bilmediğim bir nedenden dolayı this.lineChartLabels=_lineChartLabels; bu eşitleme 
     //grafiğin anlık olarak değişmesini engellemekte
     for(let i=0; i<=6 ; i++)
     {
      this.lineChartLabels[i]=_lineChartLabels[i];
     }
     //console.log(this.lineChartLabels);
    }

    public lineChartData:Array<any> = [
      {data: [10, 10, 10, 10, 10, 10, 10], label: 'Series X'},
      {data: [10, 10, 10, 10, 10, 10, 10], label: 'Series Y'},
      {data: [10, 10, 10, 10, 10, 10, 10], label: 'Series Z'}
    ];

    public lineChartLabels:string[] = ['1', '2', '3', '4', '5', '6', '7'];

    public lineChartOptions:any = {
      title: {
        display: true,
        text: 'X,Y,Z Konum Değişim (İvme) Bilgisi'
      },
      responsive: true,
      options: {
        animation: {
            duration: 0, // general animation time
        },
        hover: {
            animationDuration: 0, // duration of animations when hovering an item
        },
        responsiveAnimationDuration: 0, // animation duration after a resize
    }
    };
    
    public lineChartColors:Array<any> = [
      { // grey
        backgroundColor: 'rgba(197, 32, 32, 0.19)',
        borderColor: 'rgba(255, 0, 0, 0.3)',
        pointBackgroundColor: 'rgba(218, 16, 16, 0.6)',
        pointBorderColor: '#fff',
        pointHoverBackgroundColor: '#fff',
        pointHoverBorderColor: 'rgba(208, 20, 20, 0.93)'
      },
      { // dark grey
        backgroundColor: 'rgba(76, 191, 63, 0.34)',
        borderColor: 'rgba(63, 219, 61, 0.85)',
        pointBackgroundColor: 'rgba(63, 219, 61, 0.85)',
        pointBorderColor: '#fff',
        pointHoverBackgroundColor: '#fff',
        pointHoverBorderColor: 'rgba(76, 191, 63, 0.79)'
      },
      { // grey
        //showLine: false,
        backgroundColor: 'rgba(148,159,177,0.2)',
        borderColor: 'rgba(148,159,177,1)',
        pointBackgroundColor: 'rgba(148,159,177,1)',
        pointBorderColor: '#fff',
        pointHoverBackgroundColor: '#fff',
        pointHoverBorderColor: 'rgba(148,159,177,0.8)'
      }
    ];
    public lineChartLegend:boolean = true;
    public lineChartType:string = 'line';

    // events
  public chartClicked(e:any):void {
    console.log(e);
  }

  public chartHovered(e:any):void {
    console.log(e);
  }

    // events
    public barchartClicked(e:any):void {
      console.log(e);
    }
  
    public barchartHovered(e:any):void {
      console.log(e);
    }


  public randomize():void {
    let _lineChartData:Array<any> = new Array(this.lineChartData.length);
    for (let i = 0; i < this.lineChartData.length; i++) {
      _lineChartData[i] = {data: new Array(this.lineChartData[i].data.length), label: this.lineChartData[i].label};
      for (let j = 0; j < this.lineChartData[i].data.length; j++) {
        _lineChartData[i].data[j] = Math.floor((Math.random() * 100) + 1);
      }
    }
    this.lineChartData = _lineChartData;
  }


}
