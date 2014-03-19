package com.renaudbardet.ane.aircast
{

	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	import com.renaudbardet.ane.aircast.event.*;

	public class AirCast extends EventDispatcher {

		private static const EXTENSION_ID : String = "com.renaudbardet.ane.AirCast";
		
		private static var _instance : AirCast;

		public static var logger : IAirCastLogger;

		/** at first we only support iOS, will implement Android support when google does release the cast SDK*/
		public static function get isSupported() : Boolean
		{
			return Capabilities.manufacturer.indexOf("iOS") > -1
			/*|| Capabilities.manufacturer.indexOf("Android") > -1*/;
		}
		
		public static function getInstance() : AirCast
		{
			return _instance ? _instance : new AirCast();
		}

		private var _connectedDevice : AirCastDevice;
		private var _context : ExtensionContext;

		public function AirCast()
		{
			if (!_instance)
			{
				_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
				if (!_context)
				{
					log("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
					return;
				}
				_context.addEventListener(StatusEvent.STATUS, onStatus);
				
				_instance = this;
			}
			else
			{
				throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
			}
		}

		public function get connectedDevice():AirCastDevice { return this._connectedDevice; }

		/** initialize the cast sender with the receiver app ID */
		public function init( appID:String ):void
		{
			if (!isSupported) return;
			log( "initializing AirCast Extension with appID "+appID );
			_context.call('initNE', appID) ;
		}

		/** Perform a device scan to discover devices on the network. */
		public function scan():void
		{
			if (!isSupported) return;
			log( "initiating scan" );
			_context.call('scan') ;
		}

		/** Stop any ongoing device scan */
		public function stopScan():void
		{
			if (!isSupported) return;
			log( "stopping scan" );
			_context.call('stopScan') ;
		}

		/** Search for a device with given ID and connect to it
		 * @returns false if the device could not be found, true otherwise
		 * @note	a return of true does not mean we connected to the receiver
		 *			listen to AirCastDeviceEvent.DID_CONNECT_TO_DEVICE to know
		 *			when we successfully connected to a receiver
		 */
		public function connectToDevice( deviceID:String ):Boolean
		{
			if (!isSupported) return false;
			log( "connecting to device "+deviceID );
			return _context.call('connectToDevice', deviceID) ;
		}

		/** Ask the receiver to gracefully disconnect this sender
		 *	listen to AirCastDeviceEvent.DID_DISCONNECT to know
		 *	when we successfully disconnected from the receiver
		 */
		public function disconnectFromDevice():void
		{
			if (!isSupported) return;
			log( "disconnecting from device" );
			_context.call('disconnectFromDevice') ;
		}

		/** Load a media on the device with supplied media metadata. */
		public function loadMedia(	url:String,
									thumbnailURL:String,
									title:String,
									desc:String,
									mimeType:String,
									startTime:Number,
									autoPlay:Boolean
								):Boolean
		{
			if (!isSupported) return false;
			log( "loading media at url "+url );
			return _context.call('loadMedia', url, thumbnailURL, title, desc, mimeType, startTime, autoPlay );
		}

		/** Returns true if connected to a Chromecast device. */
		public function isConnected():Boolean
		{
			if (!isSupported) return false;
			return _context.call('isConnected');
		}

		/** Returns true if media is loaded on the device. */
		public function isPlayingMedia():Boolean
		{
			if (!isSupported) return false;
			return _context.call('isPlayingMedia');
		}

		/** set the state of the player to play */
		public function playCast():void
		{
			if (!isSupported) return;
			log( "play" );
			_context.call('playCast');
		}

		/** set the state of the player to pause */
		public function pauseCast():void
		{
			if (!isSupported) return;
			log( "pause" );
			_context.call('pauseCast');
		}

		/** Request an update of media playback stats from the Chromecast device. */
		public function updateStatsFromDevice():void
		{

			/*var statsObject = _context.call('updateStatsFromDevice');

			var mediaStatus:AirCastMediaStatus = new AirCastMediaStatus(	mediaSessionID:int,
																			playerState:int,
																			idleReason:int,
																			playbackRate:Number,
																			mediaInformation:AirCastMediaInfo,
																			statsObject.streamPosition:Number,
																			volume:Number,
																			isMuted:Boolean,
																			customData:Object
																		);

			FRESetObjectProperty(ret, (const uint8_t*)"streamPosition", streamPosition, ex);
			FRESetObjectProperty(ret, (const uint8_t*)"streamDuration", streamDuration, ex);
			FRESetObjectProperty(ret, (const uint8_t*)"playerState", playerState, ex);
			FRESetObjectProperty(ret, (const uint8_t*)"mediaInformation", mediaInformation, ex);
			*/
			
		}

		/** Sets the position of the playback on the Chromecast device. */
		public function seek( pos:Number ):void
		{
			if (!isSupported) return;
			log( "seek "+pos );
			_context.call('seek', pos);
		}

		/** Stops the media playing on the Chromecast device. */
		public function stopCast():void
		{
			if (!isSupported) return;
			log( "stop" );
			_context.call('stopCast');
		}

		/** Stops the media playing on the Chromecast device. */
		public function setVolume(value:Number):void
		{
			if (!isSupported) return;
			log( "setting volume to "+value );
			_context.call('setVolume', value);
		}
		
		/** Stops the media playing on the Chromecast device. */
		public function sendCustomEvent(protocol:String, message:String):void
		{
			if (!isSupported) return;
			log( "sending message with protocol "+protocol );
			_context.call('sendCustomEvent', message, protocol);
		}

		// ------------------------------
		// Events
		private function onStatus( event : StatusEvent ) : void
		{
			var today:Date = new Date();
			var callback:Function;
			
			if (event.code == "AirCast.deviceListChanged")
			{
				log( "received deviceListChanged" );
				var deviceList:Vector.<AirCastDevice> = new Vector.<AirCastDevice>();
				try{
					var jsonObject:Object = JSON.parse(event.level);
					for each( var deviceJsonObject:Object in (jsonObject as Array))
						deviceList.push(AirCastDevice.fromJSONObject(deviceJsonObject));
				} catch (e:*) {
					log(e.toString());
				}
				dispatchEvent( new AirCastDeviceListEvent(AirCastDeviceListEvent.DEVICE_LIST_CHANGED, deviceList) );
			}
			else if (event.code == "AirCast.didConnectToDevice")
			{
				log( "received deviceListChanged" );
				try{
					jsonObject = JSON.parse(event.level);
					var device:AirCastDevice = AirCastDevice.fromJSONObject(jsonObject);
					this._connectedDevice = device;
					dispatchEvent( new AirCastDeviceEvent(AirCastDeviceEvent.DID_CONNECT_TO_DEVICE, device) );
				} catch (e:*) {
					log(e.toString());
				}
			}
			else if (event.code == "AirCast.didDisconnect")
			{
				log( "received didDisconnect" );
				if(connectedDevice != null){
					var d:AirCastDevice = connectedDevice;
					this._connectedDevice = null;
					dispatchEvent( new AirCastDeviceEvent(AirCastDeviceEvent.DID_DISCONNECT, d) );
				}
			}
			else if (event.code == "AirCast.didReceiveMediaStateChange")
			{
				log( "received didReceiveMediaStateChange", event.level );
				try{
					jsonObject = JSON.parse(event.level);
					var status:AirCastMediaStatus = jsonObject.status != null ? 
						AirCastMediaStatus.fromJSONObject(jsonObject)
						: null;
					dispatchEvent( new AirCastMediaEvent(AirCastMediaEvent.STATUS_CHANGED, status) );
				} catch (e:*) {
					log(e.toString());
				}
			}
			else if (event.code == "AirCast.didReceiveCustomEvent")
			{
				log( "received didReceiveCustomEvent", event.level );
				try{
					jsonObject = JSON.parse(event.level);
					dispatchEvent( new AirCastCustomEvent(jsonObject.protocol, jsonObject.event) );
				} catch (e:*) {
					log(e.toString());
				}
			}
			else if (event.code == "LOGGING") // Simple log message
			{
				log(event.level);
			}
		}
		
		private static function log( ...params ) : void
		{
			if (logger != null) logger.log.apply( null, params );
		}

	}

}