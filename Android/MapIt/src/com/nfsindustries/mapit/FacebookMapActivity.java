package com.nfsindustries.mapit;

import java.text.Collator;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import pl.mg6.android.maps.extensions.ClusteringSettings;
import pl.mg6.android.maps.extensions.DefaultClusterOptionsProvider;
import pl.mg6.android.maps.extensions.GoogleMap;
import pl.mg6.android.maps.extensions.GoogleMap.InfoWindowAdapter;
import pl.mg6.android.maps.extensions.Marker;
import pl.mg6.android.maps.extensions.MarkerOptions;
import pl.mg6.android.maps.extensions.SupportMapFragment;

import com.facebook.HttpMethod;
import com.facebook.Request;
import com.facebook.Response;
import com.facebook.Session;
import com.facebook.model.GraphObject;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.maps.model.LatLng;

import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

public class FacebookMapActivity extends FragmentActivity {
	// Google Map
	private GoogleMap googleMap;
	private boolean currentLocationOpt;
	//private List<Marker> declusterifiedMarkers;
	//ArrayList<Friend> fbFriendArray;

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
			initilizeMap();
		} catch (Exception e) {
			e.printStackTrace();
		}
		getFBFriendsLocation();
	}

	private void addMarker(double latitude, double longitude, String markerTitle){
		// create marker
		if(googleMap == null){
			Log.e("googleMap", "NULL");
		}
		try{
			//BitmapDescriptor icon = BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_BLUE);
			MarkerOptions options = new MarkerOptions();
			googleMap.addMarker(options.title(markerTitle).position(new LatLng(latitude, longitude)));
			
		}catch(NullPointerException npEx){
			Log.e("addMarker", "NullPointerException");
			//npEx.printStackTrace();
		}
		/*
		 * // ROSE color icon
		marker.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_ROSE));

		// GREEN color icon
		marker.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN));
		 */
	}
	/*
	private void declusterify(Marker cluster) {
		clusterifyMarkers();
		declusterifiedMarkers = cluster.getMarkers();
		LatLng clusterPosition = cluster.getPosition();
		double distance = calculateDistanceBetweenMarkers();
		double currentDistance = -declusterifiedMarkers.size() / 2 * distance;
		for (Marker marker : declusterifiedMarkers) {
			marker.setData(marker.getPosition());
			marker.setClusterGroup(ClusterGroup.NOT_CLUSTERED);
			LatLng newPosition = new LatLng(clusterPosition.latitude, clusterPosition.longitude + currentDistance);
			marker.animatePosition(newPosition);
			currentDistance += distance;
		}
	}
	
	private double calculateDistanceBetweenMarkers() {
		Projection projection = googleMap.getProjection();
		Point point = projection.toScreenLocation(new LatLng(0.0, 0.0));
		point.x += getResources().getDimensionPixelSize(R.dimen.distance_between_markers);
		LatLng nextPosition = projection.fromScreenLocation(point);
		return nextPosition.longitude;
	}

	private void clusterifyMarkers() {
		if (declusterifiedMarkers != null) {
			for (Marker marker : declusterifiedMarkers) {
				LatLng position = (LatLng) marker.getData();
				marker.setPosition(position);
				marker.setClusterGroup(ClusterGroup.DEFAULT);
			}
			declusterifiedMarkers = null;
		}
	}
    */
	/**
	 * function to load map. If map is not created it will create it for you
	 * */
	private void checkGooglePlayServices()
	{
		int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(getApplicationContext());

		if (resultCode == ConnectionResult.SUCCESS){
			Log.d("FacebookMapActivity", "isGooglePlayServicesAvailable SUCCESS");
		}else{
			GooglePlayServicesUtil.getErrorDialog(resultCode, this, resultCode);
		}
	}

	private void initilizeMap() {
		checkGooglePlayServices();
		if (googleMap == null) {
			FragmentManager fm = getSupportFragmentManager();
			SupportMapFragment f = (SupportMapFragment) fm.findFragmentById(R.id.facebookMap);
			googleMap = f.getExtendedMap();
			googleMap.setClustering(new ClusteringSettings().clusterOptionsProvider(new DefaultClusterOptionsProvider(getResources())).addMarkersDynamically(true));
			googleMap.setMyLocationEnabled(true); // false to disable
			googleMap.getUiSettings().setCompassEnabled(true);
			//googleMap.getUiSettings().setMyLocationButtonEnabled(true);
			//googleMap.getUiSettings().setRotateGesturesEnabled(true);
			
			googleMap.setInfoWindowAdapter(new InfoWindowAdapter() {

				private TextView tv;
				{
					tv = new TextView(FacebookMapActivity.this);
					tv.setTextColor(Color.BLACK);
				}

				private Collator collator = Collator.getInstance();
				private Comparator<Marker> comparator = new Comparator<Marker>() {
					public int compare(Marker lhs, Marker rhs) {
						String leftTitle = lhs.getTitle();
						String rightTitle = rhs.getTitle();
						if (leftTitle == null && rightTitle == null) {
							return 0;
						}
						if (leftTitle == null) {
							return 1;
						}
						if (rightTitle == null) {
							return -1;
						}
						return collator.compare(leftTitle, rightTitle);
					}
				};

				@Override
				public View getInfoWindow(Marker marker) {
					return null;
				}

				@Override
				public View getInfoContents(Marker marker) {
					if (marker.isCluster()) {
						List<Marker> markers = marker.getMarkers();
						int i = 0;
						String text = "";
						while (i < 3 && markers.size() > 0) {
							Marker m = Collections.min(markers, comparator);
							String title = m.getTitle();
							if (title == null) {
								break;
							}
							text += title + "\n";
							markers.remove(m);
							i++;
						}
						if (text.length() == 0) {
							text = "";
						} else if (markers.size() > 0) {
							text += "and " + markers.size() + " more...";
						} else {
							text = text.substring(0, text.length() - 1);
						}
						tv.setText(text);
						return tv;
					} else {
						Object data = marker.getData();
						if (data instanceof MutableData) {
							MutableData mutableData = (MutableData) data;
							tv.setText("Value: " + mutableData.value);
							return tv;
						}
					}

					return null;
				}
			});

			
			/*
			googleMap.setOnMarkerClickListener(new GoogleMap.OnMarkerClickListener() {
				@Override
				public boolean onMarkerClick(Marker marker) {
					if (marker.isCluster()) {
						declusterify(marker);
						return true;
					}
					return false;
				}
			});
			googleMap.setOnMapClickListener(new GoogleMap.OnMapClickListener() {
				@Override
				public void onMapClick(LatLng position) {
					clusterifyMarkers();
				}
			});
			*/
			// check if map is created successfully or not
			if (googleMap == null) {
				//Log.e("googleMap", "null");
				Toast.makeText(getApplicationContext(),
						"Sorry! unable to create maps", Toast.LENGTH_SHORT)
						.show();
			}
		}
	}

	private void getFBFriendsLocation()
	{
		String fqlQuery = "{" +
				"'allfriends':'SELECT uid2 FROM friend WHERE uid1=me()'," +
				"'frienddetails':'SELECT uid, name, pic, hometown_location, current_location FROM user WHERE uid IN ( SELECT uid2 FROM friend WHERE uid1 = me() )'," +
				"}";
		Bundle params = new Bundle();
		params.putString("q", fqlQuery);
		Session session = Session.getActiveSession();
		Request request = new Request(session,
				"/fql",                         
				params,                         
				HttpMethod.GET,                 
				new Request.Callback(){         

			@Override
			public void onCompleted(Response response) {
				GraphObject graphObject = response.getGraphObject();
				if (graphObject != null) {
					JSONObject jsonObject = graphObject.getInnerJSONObject();
					//fql_result_set
					Log.d("getInnerJSONObject", jsonObject.toString());
					try {
						JSONArray dataJSONArray = jsonObject.getJSONArray("data");
						//Log.d("data", dataJSONArray.toString());
						JSONObject fqlResultSetJSONObj = dataJSONArray.getJSONObject(1);
						//Log.d("fql_result_set", fqlResultSetJSONObj.toString());
						
						JSONArray array = fqlResultSetJSONObj.getJSONArray("fql_result_set");
						for (int i = 0; i < array.length(); i++) {
							JSONObject userJSONObj = (JSONObject) array.get(i);
							//Log.d("fql", "name = " + userJSONObj.get("name"));

							try{
								JSONObject locationJSONObj = null;
								if(currentLocationOpt)
								{
									locationJSONObj = userJSONObj.getJSONObject("current_location");
								}
								else {
									locationJSONObj = userJSONObj.getJSONObject("hometown_location");
								}
								double usrLatitude = locationJSONObj.getDouble("latitude");
								double usrLongitude = locationJSONObj.getDouble("longitude");
								String usrName = userJSONObj.getString("name");
								//String usrCity = locationJSONObj.getString("name");
								//Friend fbFriend = new Friend(usrName, usrCity, usrLatitude, usrLongitude);
								//fbFriendArray.add(fbFriend);
								//Log.d("FB_Friend", fbFriend.name);
								addMarker(usrLatitude, usrLongitude, usrName);
							}catch(JSONException e) {
								Log.e("USER_LOCATION", "JSONException");
								//e.printStackTrace();
							}

						} 
					} catch (JSONException e) {
						Log.e("USER", "JSONException");
					}
				}
			}
		});

		Request.executeBatchAsync(request);  
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

