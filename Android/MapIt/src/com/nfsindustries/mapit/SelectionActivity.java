package com.nfsindustries.mapit;

import com.facebook.Session;
import com.facebook.SessionState;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

public class SelectionActivity extends Activity {
	static final int FACEBOOK_LOGIN_REQUEST = 1;  // The request code
	Button currentLocBtn;
	Button hometownBtn;
	TextView fbInfoTV;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_selection);
		
		currentLocBtn = (Button)findViewById(R.id.currentLocationButton);
		hometownBtn = (Button)findViewById(R.id.homeTownButton);
		fbInfoTV = (TextView)findViewById(R.id.textView1);
		
		currentLocBtn.setOnClickListener(new OnClickListener(){
	        @Override
	        //On click function
	        public void onClick(View view) {
	        	Intent facebookCurrentLocationMapIntent = new Intent(SelectionActivity.this, FacebookMapActivity.class);
	        	facebookCurrentLocationMapIntent.putExtra("current_location", true);
	        	startActivity(facebookCurrentLocationMapIntent);
	        }
	    });
		
		hometownBtn.setOnClickListener(new OnClickListener(){
	        @Override
	        //On click function
	        public void onClick(View view) {
	        	Intent facebookHometownMapIntent = new Intent(SelectionActivity.this, FacebookMapActivity.class);
	        	facebookHometownMapIntent.putExtra("current_location", false);
	        	startActivity(facebookHometownMapIntent);
	        }
	    });
	    
	}
	
	@Override
	protected void onResume()
	{
		super.onResume();
		//start Facebook Login
		  Session.openActiveSession(this, true, new Session.StatusCallback() {

		    // callback when session changes state
			@Override
			public void call(Session session, SessionState state,
					Exception exception) {
		        if (session.isOpened()) 
		        {
		        	hometownBtn.setVisibility(View.VISIBLE);
		        	currentLocBtn.setVisibility(View.VISIBLE);
		        	fbInfoTV.setVisibility(View.VISIBLE);
		        }
		        else 
		        {
		        	hometownBtn.setVisibility(View.GONE);
		        	currentLocBtn.setVisibility(View.GONE);
		        	fbInfoTV.setVisibility(View.GONE);
		        }
			}
		  }); 
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.selection, menu);
		return true;
	}
	
	@Override
	  public void onActivityResult(int requestCode, int resultCode, Intent data) {
	      super.onActivityResult(requestCode, resultCode, data);
	      Session.getActiveSession().onActivityResult(this, requestCode, resultCode, data);
	  }
}
