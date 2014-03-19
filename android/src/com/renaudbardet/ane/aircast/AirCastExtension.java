package com.renaudbardet.ane.aircast;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class AirCastExtension implements FREExtension
{
	
	public static String TAG = "AirCast";
	private static Boolean PRINT_LOG = true;
	
	public static AirCastExtensionContext context;

	public FREContext createContext(String extId)
	{
		return context = new AirCastExtensionContext();
	}

	public void dispose()
	{
		context = null;
	}
	
	public void initialize() {}
	
	public static void log(String message)
	{
		if (PRINT_LOG) Log.d(TAG, message);
		if (context != null && message != null) context.dispatchStatusEventAsync("LOGGING", message);
	}
	
	public static int getResourceId(String name)
	{
		return context != null ? context.getResourceId(name) : 0;
	}
}