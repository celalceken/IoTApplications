import { Component } from '@angular/core';
import { NavController ,ToastController } from 'ionic-angular';

//Servis
import { socketservice } from '../../app/socket.service';


@Component({
  selector: 'page-contact',
  templateUrl: 'contact.html'
})
export class ContactPage {
  public batterylevel =0;
  public temp =0;
  
  public doughnutChartOptions:any = {
    animation: 
    {
      animateRotate:true
    },
    title: {
      display: true,
      text: 'Batarya Seviyesi'
  }
  }

  public doughnutChartLabels: string[] = [' Belirsiz Boş', ' Belirsiz Dolu'] ;
  public doughnutChartData:number[] = [100-this.batterylevel, this.batterylevel];
  public doughnutChartType:string = 'doughnut';

  constructor(public navCtrl: NavController,
              private toastCtrl: ToastController,
              private ss:socketservice) {
    ss.getMessage().subscribe((msg: any[]) => {
      // const myObjStr = JSON.stringify(msg);
      //console.log(JSON.parse(myObjStr));
      //İkinci gelişte bozuk bir şekilde animasyon yapmasını istemezsek
      //this.doughnutChartOptions.animation.animateRotate =false;
      this.batterylevel = parseInt(this.ss.getData(msg,"BAT"));

      if (this.temp != this.batterylevel)
      {
              this.doughnutChartLabels = ['Boş', 'Dolu'];
              this.doughnutChartData[0] = 100-this.batterylevel ;
              this.doughnutChartData[1] = this.batterylevel;
              this.doughnutChartType = 'doughnut';
      }

        this.temp = this.batterylevel;

    })

  }
  showToast(msg) {
    let toast = this.toastCtrl.create({
      message: msg,
      duration: 2000
    });
    toast.present();
  }
  // events
  public chartClicked(e:any):void {
    console.log(e);
  }

  public chartHovered(e:any):void {
    console.log(e);
  }
}
