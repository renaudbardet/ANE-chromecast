package com.renaudbardet.ane.aircast.event {
	
	import flash.events.Event;

	public class AirCastCustomEvent extends Event {

		private var _message:String;
		
		public function get message():String { return this._message; }

		public function AirCastCustomEvent( protocol:String, message:String )
		{

			super(protocol);

			this._message = message;

		}

	}

}