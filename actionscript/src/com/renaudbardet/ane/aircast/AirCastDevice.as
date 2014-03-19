package com.renaudbardet.ane.aircast{

	public class AirCastDevice {

		private var _ipAddress:String;
		private var _servicePort:uint;
		private var _deviceID:String;
		private var _friendlyName:String;
		private var _manufacturer:String;
		private var _modelName:String;
		private var _icons:Vector.<AirCastImage>;

		public function AirCastDevice( 	ipAddress:String,
								servicePort:uint,
								deviceID:String,
								friendlyName:String,
								manufacturer:String,
								modelName:String,
								icons:Vector.<AirCastImage> )
		{
			_ipAddress = ipAddress;
			_servicePort = servicePort;
			_deviceID = deviceID;
			_friendlyName = friendlyName;
			_manufacturer = manufacturer;
			_modelName = modelName;
			_icons  = icons;
		}
		
		public function get ipAddress():String { return this._ipAddress; }
		public function get servicePort():uint { return this._servicePort; }
		public function get deviceID():String { return this._deviceID; }
		public function get friendlyName():String { return this._friendlyName; }
		public function get manufacturer():String { return this._manufacturer; }
		public function get modelName():String { return this._modelName; }
		public function get icons():Vector.<AirCastImage> { return this._icons.slice(); }

		public static function fromJSONObject(jsonObject:Object):AirCastDevice
		{
			
			var icons:Vector.<AirCastImage> = new Vector.<AirCastImage>();
			if (jsonObject.icons!=null)
				for each (var iconJsonObject:Object in (jsonObject.icons as Array))
					icons.push(AirCastImage.fromJSONObject(iconJsonObject));

			return new AirCastDevice(
					jsonObject.ipAddress,
					jsonObject.servicePort,
					jsonObject.deviceID,
					jsonObject.friendlyName,
					jsonObject.manufacturer,
					jsonObject.modelName,
					icons
				);

		}

	}
}