import { Injectable } from '@angular/core';
import { Socket } from 'ng-socket-io';

import { Platform } from 'ionic-angular';
import 'rxjs/add/operator/map';
@Injectable()
export class socketservice {
  isApp: boolean = true;

constructor(private socket: Socket,public platform: Platform) { }

/*
sendMessage(msg: string) {
this.socket.emit("message", msg);
}
*/
/*
reset(){
this.socket.emit("reset");
}
*/


  getMessage() {
    return this.socket.fromEvent<any>("alldata").map(res => res);
  }

  close() {
  this.socket.disconnect()
  }

/**
 * Soketden alınan frame ayrıştır
 * 
 */

  getData (data,sensorName){
    //console.log(data.sensor[sensorName]);
    return data.sensor[sensorName];
  }
  
  getDataTime(data){
    return data.time;
  }



  public route():void {
    let platforms = this.platform.platforms();
      let platformList = platforms.join(', ');
      console.log(platformList);
      //Şuan için sadece core da çalışsın raspery e yüklerken mobil webde false değeri alıcaz
    if (this.platform.is('core') /*|| this.platform.is('mobileweb')*/) {
      console.log("I am core")
      this.isApp = false;
    
      //window.location.href = 'http://localhost:8100/contact.html';
    }
    console.log(this.isApp);

    if (this.platform.is('core' /*|| this.platform.is('mobileweb')*/)) {
      // This will only print when on iOS
      window.location.href = 'http://localhost:8080/';
      console.log('I am an Mobile Web device! or I am a core');
    }

      /* 
      Bu kısım denedim çalışıyor nodejs üzerinde çalışan web sitesi geliyor. Ama doğru yöntem olduğunu sanmıyorum
                if (this.plt.is('ios')) {
                  // This will only print when on iOS
                  console.log('I am an iOS device!');
                }
                if (this.plt.is('android')) {
                  console.log('I am an Android device!');
                }
                if (this.plt.is('windows')) {
                  // This will only print when on iOS
                  console.log('I am an Windows device!');
                }if (this.plt.is('mobileweb')) {
                  // This will only print when on iOS
                  window.location.href = 'http://localhost:8080/';
                  console.log('I am an Mobile Web device!');
                }*/
  }

}

  