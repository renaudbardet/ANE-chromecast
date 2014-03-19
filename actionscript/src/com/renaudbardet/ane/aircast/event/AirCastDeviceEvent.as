package com.renaudbardet.ane.aircast.event {
	
	import flash.events.Event;

	import com.renaudbardet.ane.aircast.AirCastDevice;

	public class AirCastDeviceEvent extends Event {

		public static const DID_CONNECT_TO_DEVICE:String = "AirCastDeviceEvent.DID_CONNECT_TO_DEVICE";
		public static const DID_DISCONNECT:String = "AirCastDeviceEvent.DID_DISCONNECT";

		private var _device:AirCastDevice;
		
		public function get device():AirCastDevice { return this._device; }

		public function AirCastDeviceEvent( type:String, device:AirCastDevice )
		{

			super(type);

			this._device = device;

		}

	}

}