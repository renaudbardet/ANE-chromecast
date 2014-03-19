package com.renaudbardet.ane.aircast.event {
	
	import flash.events.Event;

	import com.renaudbardet.ane.aircast.AirCastMediaStatus;

	public class AirCastMediaEvent extends Event {

		public static const STATUS_CHANGED:String = "AirCastDeviceEvent.STATUS_CHANGED";

		private var _status:AirCastMediaStatus;
		
		public function get status():AirCastMediaStatus { return this._status; }

		public function AirCastMediaEvent( type:String, status:AirCastMediaStatus )
		{

			super(type);

			this._status = status;

		}

	}

}