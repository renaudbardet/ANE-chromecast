package com.renaudbardet.ane.aircast;

import java.util.HashMap;
import java.util.Map;

import android.support.v7.media.MediaRouteSelector;
import android.support.v7.media.MediaRouter;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.google.android.gms.cast.Cast;
import com.google.android.gms.cast.CastMediaControlIntent;
import com.google.android.gms.common.api.GoogleApiClient;

public class AirCastExtensionContext extends FREContext
{

	private String appId;
	private MediaRouter mediaRouter;
	private Boolean isScanning;
	private MediaRouteSelector mediaRouteSelector;
	private GoogleApiClient apiClient;
	
	public AirCastExtensionContext() {
		
		this.mediaRouter = MediaRouter.getInstance(getActivity());
		mediaRouteSelector = new MediaRouteSelector.Builder()
			.addControlCategory(CastMediaControlIntent.categoryForCast(this.appId))
			.build();
		
		isScanning = false;
		
	}
	
	@Override
	public void dispose()
	{
		AirCastExtension.context = null;
		mediaRouter.removeCallback(mediaRouteCallback);
	}
	
	private BaseFunction initNE = new BaseFunction() { @Override public FREObject call(FREContext context, FREObject[] args) {
		
		appId = getStringFromFREObject(args[0]);
		return null;
		
	}};
	
	private BaseFunction scan = new BaseFunction() {
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		if(!isScanning)
			mediaRouter.addCallback(mediaRouteSelector, mediaRouteCallback, MediaRouter.CALLBACK_FLAG_PERFORM_ACTIVE_SCAN);
		isScanning = true;
		return null;
		
	}};
	
	private BaseFunction stopScan = new BaseFunction() {
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		if(isScanning)
			mediaRouter.removeCallback(mediaRouteCallback);
		isScanning = false;
		return null;
		
	}};
	
	private BaseFunction connectToDevice = new BaseFunction() {
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		String deviceID = getStringFromFREObject(args[0]);
		RouteInfo route = null;
		for( RouteInfo r : mediaRouter.getRoutes() ){
			if( r.getId() == deviceID ) {
				route = r;
				break;
			}
		}
		if( route != null ) mediaRouter.selectRoute(route);
		try {
			return FREObject.newObject( route != null );
		} catch (FREWrongThreadException e) {
			return null;
		}
		
	}};
	
	private BaseFunction disconnectFromDevice = new BaseFunction() {
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		mediaRouter.selectRoute(null);
		return null;
		
	}};
	
	private BaseFunction loadMedia = new BaseFunction() {
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		return null;
		
	}};
	
	private BaseFunction isConnected = new BaseFunction() {
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		try {
			return FREObject.newObject( apiClient != null );
		} catch (FREWrongThreadException e) {
			return null;
		}
		
	}};
	
	private BaseFunction isPlayingMedia = new BaseFunction() { 
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		return null;
		
	}};
	
	private BaseFunction playCast = new BaseFunction() { 
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		return null;
		
	}};
	
	private BaseFunction pauseCast = new BaseFunction() { 
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		return null;
		
	}};
	
	private BaseFunction updateStatsFromDevice = new BaseFunction() { 
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		return null;
		
	}};
	
	private BaseFunction seek = new BaseFunction() { 
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		return null;
		
	}};
	
	private BaseFunction stopCast = new BaseFunction() { 
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		return null;
		
	}};
	
	private BaseFunction setVolume = new BaseFunction() { 
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		return null;
		
	}};
	
	private BaseFunction sendCustomEvent = new BaseFunction() { 
	@Override public FREObject call(FREContext context, FREObject[] args) {
		
		if(mediaRouter.getSelectedRoute() != null) {
			
		}
		return null;
		
	}};
	
	private Cast.Listener castClientListener = new Cast.Listener() {
		
	};
	
	private 
	
	private MediaRouter.Callback mediaRouteCallback = new Callback() {
		
		@Override
		public void onRouteSelected(MediaRouter router, MediaRouter.RouteInfo route){
			
			Cast.CastOptions.Builder apiOptionsBuilder = Cast.CastOptions
					.builder(route, castClientListener);
			
			apiClient = new GoogleApiClient.Builder(this)
                    .addApi(Cast.API, apiOptionsBuilder.build())
                    .addConnectionCallbacks(mConnectionCallbacks)
                    .addOnConnectionFailedListener(mConnectionFailedListener)
                    .build();
			
		}
		
		@Override
		public void onRouteUnselected(MediaRouter router, MediaRouter.RouteInfo route){
			
		}
		
		@Override
		public void onRouteAdded(MediaRouter router, MediaRouter.RouteInfo route){
			
		}
		
		@Override
		public void onRouteRemoved(MediaRouter router, MediaRouter.RouteInfo route){
			
		}
		
		@Override
		public void onRouteChanged(MediaRouter router, MediaRouter.RouteInfo route){
			
		}
		
		@Override
		public void onRouteVolumeChanged(MediaRouter router, MediaRouter.RouteInfo route){
			
		}
		
		@Override
		public void onRoutePresentationDisplayChanged(MediaRouter router, MediaRouter.RouteInfo route){
			
		}
		
		@Override
		public void onProviderAdded(MediaRouter router, MediaRouter.ProviderInfo provider){
			
		}
		
		@Override
		public void onProviderRemoved(MediaRouter router, MediaRouter.ProviderInfo provider){
			
		}
		
		@Override
		public void onProviderChanged(MediaRouter router, MediaRouter.ProviderInfo provider){
			
		}
		
	};
	
	@Override
	public Map<String, FREFunction> getFunctions()
	{
		Map<String, FREFunction> functions = new HashMap<String, FREFunction>();
		
		functions.put("initNE", initNE);
		functions.put("scan", scan);
		functions.put("stopScan", stopScan);
		functions.put("connectToDevice", connectToDevice);
		functions.put("disconnectFromDevice", disconnectFromDevice);
		functions.put("loadMedia", loadMedia);
		functions.put("isConnected", isConnected);
		functions.put("isPlayingMedia", isPlayingMedia);
		functions.put("playCast", playCast);
		functions.put("pauseCast", pauseCast);
		functions.put("updateStatsFromDevice", updateStatsFromDevice);
		functions.put("seek", seek);
		functions.put("stopCast", stopCast);
		functions.put("setVolume", setVolume);
		functions.put("sendCustomEvent", sendCustomEvent);
		return functions;	
	}
	
}
