package rad;

import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.audio.AnalyserNode;
import js.html.audio.AudioContext;
import js.lib.Uint8Array;

class App {

	static var canvas : CanvasElement;
	static var ctx : CanvasRenderingContext2D;
	static var analyser : AnalyserNode;
	static var timeData : Uint8Array;
	static var color = "#fff";
	static var started = false;

    static function update( time : Float ) {

		window.requestAnimationFrame( update );

		analyser.getByteTimeDomainData( timeData );

		ctx.clearRect( 0, 0, canvas.width, canvas.height );

		var v : Float;
		var x : Float;
		var y : Float;
		var hw = canvas.width/2;
		var hh = canvas.height/2;

		ctx.strokeStyle = color;
		ctx.lineWidth = 1;
		ctx.beginPath();
		for( i in 0...analyser.frequencyBinCount ) {
			v = i / 180 * Math.PI;
			x = Math.cos(v) * timeData[i];
			y = Math.sin(v) * timeData[i];
			ctx.lineTo( hw + x, hh + y );
		}
		ctx.stroke();
    }

    static function main() {

		window.onload = function() {

			var body = document.body;

			canvas = cast body.querySelector("canvas.spectrum");
			canvas.width = window.innerWidth;
			canvas.height = window.innerHeight;

			window.oncontextmenu = function(e){
				e.preventDefault();
			}
			window.onresize = function(){
				canvas.width = window.innerWidth;
				canvas.height = window.innerHeight;
			}

			var btn = body.querySelector(".start");

			btn.onclick = function() {

				btn.textContent = 'CONNECTING';
				btn.onclick = null;

				ctx = canvas.getContext2d();

				var audioElement = document.createAudioElement();
				//audioElement.autoplay = true;
				//audioElement.preload = "metadata";
				audioElement.preload = "none";
				audioElement.crossOrigin = "anonymous";
				audioElement.controls = false;
				audioElement.play();

				var sourceElement = document.createSourceElement();
				sourceElement.type = 'application/ogg';
				sourceElement.src = 'http://195.201.41.121:8000/panzerradio';
				audioElement.appendChild( sourceElement );

				/*
				audioElement.onloadedmetadata = function(e) {
					trace(e);
				}
				*/
				audioElement.onpause = function(e) {
					trace(e);
				}
				audioElement.onplaying = function() {

					if( started )
						return;

					started = true;

					btn.remove();

					//document.querySelector(".preload").remove();

					var audio = new AudioContext();

					//var gain

					analyser = audio.createAnalyser();
					//analyser.fftSize = 2048;
					analyser.fftSize = 2048;
					//analyser.smoothingTimeConstant = 0.8;
					//analyser.minDecibels = -140;
					//analyser.maxDecibels = 0;
					analyser.connect( audio.destination );

					//freqData = new Uint8Array( analyser.frequencyBinCount );
					timeData = new Uint8Array( analyser.frequencyBinCount );

					var source = audio.createMediaElementSource( audioElement );
					source.connect( analyser );

					window.requestAnimationFrame( update );
				}
			}
		}
    }

}
