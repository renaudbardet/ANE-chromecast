package com.renaudbardet.ane.aircast{

	public class AirCastMediaInfo {

		/** A stream type of "none". */
		public static const MEDIA_STREAM_TYPE_NONE:int = 0;
		/** A buffered stream type. */
		public static const MEDIA_STREAM_TYPE_BUFFERED:int = 1;
		/** A live stream type. */
		public static const MEDIA_STREAM_TYPE_LIVE:int = 2;
		/** An unknown stream type. */
		public static const MEDIA_STREAM_TYPE_UNKNOWN:int = 99;
		
		private var _streamType:int;
		private var _contentType:String;
		private var _metadata:AirCastMediaMetadata;
		private var _streamDuration:Number;
		private var _customData:Object;

		public function AirCastMediaInfo( 	streamType:int,
											contentType:String,
											metadata:AirCastMediaMetadata,
											streamDuration:Number,
											customData:Object
										)
		{
			_streamType = streamType;
			_contentType = contentType;
			_metadata = metadata;
			_streamDuration = streamDuration;
			_customData = customData;
		}
		
		/** The stream type. */
		public function get streamType():int { return this._streamType; }
		/** The content (MIME) type. */
		public function get contentType():String { return this._contentType; }
		/** The media item metadata. */
		public function get metadata():Object { return this._metadata; }
		/** The length of time for the stream, in seconds. */
		public function get streamDuration():Number { return this._streamDuration; }
		/** The custom data, if any. */
		public function get customData():Object { return this._customData; }

		public static function fromJSONObject(jsonObject:Object):AirCastMediaInfo
		{
			
			return new AirCastMediaInfo(
					jsonObject.streamType,
					jsonObject.contentType,
					AirCastMediaMetadata.fromJSONObject( jsonObject.metadata ),
					jsonObject.streamDuration,
					jsonObject.customData
				);

		}

	}
}