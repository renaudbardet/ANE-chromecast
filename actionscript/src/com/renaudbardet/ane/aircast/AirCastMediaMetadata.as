package com.renaudbardet.ane.aircast{

	public class AirCastMediaMetadata {


 		/** A media type representing generic media content. */
 		public static const MEDIA_METADATA_TYPE_GENERIC:int = 0;
 		/** A media type representing a movie. */
 		public static const MEDIA_METADATA_TYPE_MOVIE:int = 1;
 		/** A media type representing an TV show. */
 		public static const MEDIA_METADATA_TYPE_TVSHOW:int = 2;
 		/** A media type representing a music track. */
 		public static const MEDIA_METADATA_TYPE_MUSICTRACK:int = 3;
 		/** A media type representing a photo. */
 		public static const MEDIA_METADATA_TYPE_PHOTO:int = 4;
 		/** The smallest media type value that can be assigned for application-defined media types. */
 		public static const MEDIA_METADATA_TYPE_USER:int = 100;

		private var _mediaDataType:int;
		private var _images:Vector.<AirCastImage>;
		private var _fields:Object;

		public function AirCastMediaMetadata( 	mediaDataType:int,
												images:Vector.<AirCastImage>,
												fields:Object )
		{
			_mediaDataType=mediaDataType;
			_images=images;
			_fields=fields;
		}
		
		public function get mediaDataType():int { return this._mediaDataType; }
		public function get images():Vector.<AirCastImage> { return this._images.slice(); }
		public function get fields():Object { return this._fields; }

		public static function fromJSONObject(jsonObject:Object):AirCastMediaMetadata
		{
			
			var images:Vector.<AirCastImage> = new Vector.<AirCastImage>();
			for each ( var imageJsonObject:Object in (jsonObject.images as Array))
				images.push(AirCastImage.fromJSONObject( imageJsonObject ));

			return new AirCastMediaMetadata(
					jsonObject.mediaDataType,
					images,
					jsonObject.fields
				);

		}

	}
}