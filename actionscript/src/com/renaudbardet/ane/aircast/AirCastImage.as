package com.renaudbardet.ane.aircast{

	public class AirCastImage {

		private var _url:String;
		private var _width:int;
		private var _height:int;

		public function AirCastImage( 	url,
										width,
										height )
		{
			_url = url;
			_width = width;
			_height = height;
		}
		
		public function get url():String { return this._url; }
		public function get width():int { return this._width; }
		public function get height():int { return this._height; }

		public static function fromJSONObject(jsonObject:Object):AirCastImage
		{
			
			return new AirCastImage(
					jsonObject.url,
					jsonObject.width,
					jsonObject.height
				);

		}

	}
}