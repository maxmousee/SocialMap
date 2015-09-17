package com.nfsindustries.mapit;

import com.google.android.gms.maps.model.LatLng;

import android.os.Bundle;
import android.support.v4.app.FragmentActivity;

public class FacebookMapActivity extends FragmentActivity {
	// Google Map
	//private GoogleMap googleMap;
	private boolean currentLocationOpt;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.facebook_map_activity);
		if (savedInstanceState == null) {
		    Bundle extras = getIntent().getExtras();
		    if(extras == null) {
		    	currentLocationOpt = true;
		    } else {
		    	currentLocationOpt = extras.getBoolean("current_location", true);
		    }
		} else {
			currentLocationOpt = savedInstanceState.getBoolean("current_location", true);
		}
		try {
			// Loading map
		} catch (Exception e) {
			e.printStackTrace();
		}
	}


	@SuppressWarnings("unused")
	private static class MutableData {

		private int value;

		private LatLng position;

		
		public MutableData(int value, LatLng position) {
			this.value = value;
			this.position = position;
		}
	}
	
}

