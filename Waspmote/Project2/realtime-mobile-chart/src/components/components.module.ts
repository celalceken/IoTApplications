import { NgModule } from '@angular/core';



//NgIf, NgForOf gibi tüm Temel metotları içeren common
import { CommonModule } from '@angular/common';
// n2 chartsı seçtim sebebi en stabil olarak tavsiye edilmesi
import { ChartsModule } from 'ng2-charts';
//Uygulama Chart
//npm install ng2-charts --save
//npm install chart.js --save


@NgModule({
	declarations: [],
	imports: [
		CommonModule,
		ChartsModule
	],
	exports: []
})
export class ComponentsModule {}
